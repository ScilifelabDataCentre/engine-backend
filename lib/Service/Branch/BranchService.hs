module Service.Branch.BranchService
  ( getBranches
  , createBranch
  , createBranchWithParams
  , getBranchById
  , modifyBranch
  , deleteBranch
  , getBranchState
  -- Helpers
  , heGetBranchById
  , hmGetBranchById
  , heGetBranchState
  ) where

import Control.Lens ((^.))
import Control.Monad.Reader (liftIO)
import Data.Time
import Data.UUID as U

import Api.Resource.Branch.BranchChangeDTO
import Api.Resource.Branch.BranchDTO
import Api.Resource.Branch.BranchWithStateDTO
import Api.Resource.Organization.OrganizationDTO
import Api.Resource.User.UserDTO
import Database.DAO.Branch.BranchDAO
import Database.DAO.Event.EventDAO
import Database.DAO.KnowledgeModel.KnowledgeModelDAO
import Database.DAO.Migrator.MigratorDAO
import Database.DAO.Package.PackageDAO
import LensesConfig
import Localization
import Model.Branch.Branch
import Model.Branch.BranchState
import Model.Context.AppContext
import Model.Context.AppContextHelpers
import Model.Error.Error
import Model.Error.ErrorHelpers
import Model.Event.Event
import Model.Event.KnowledgeModel.KnowledgeModelEvent
import Model.Migrator.MigratorState
import Service.Branch.BranchMapper
import Service.Branch.BranchValidation
import Service.KnowledgeModel.KnowledgeModelService
import Service.Organization.OrganizationService
import Service.Package.PackageService
import Util.Uuid

getBranches :: AppContextM (Either AppError [BranchWithStateDTO])
getBranches = heGetOrganization $ \organization -> heFindBranches $ \branches -> toDTOs organization branches
  where
    toDTOs :: OrganizationDTO -> [Branch] -> AppContextM (Either AppError [BranchWithStateDTO])
    toDTOs organization = Prelude.foldl (foldBranch organization) (return . Right $ [])
    foldBranch ::
         OrganizationDTO
      -> AppContextM (Either AppError [BranchWithStateDTO])
      -> Branch
      -> AppContextM (Either AppError [BranchWithStateDTO])
    foldBranch organization eitherDtosIO branch = do
      eitherDtos <- eitherDtosIO
      case eitherDtos of
        Right dtos ->
          heGetBranchState (U.toString $ branch ^. uuid) $ \branchState ->
            return . Right $ dtos ++ [toWithStateDTO branch branchState organization]
        Left error -> return . Left $ error

createBranch :: BranchChangeDTO -> AppContextM (Either AppError BranchDTO)
createBranch reqDto = do
  bUuid <- liftIO generateUuid
  now <- liftIO getCurrentTime
  heGetCurrentUser $ \currentUser -> createBranchWithParams bUuid now currentUser reqDto

createBranchWithParams :: U.UUID -> UTCTime -> UserDTO -> BranchChangeDTO -> AppContextM (Either AppError BranchDTO)
createBranchWithParams bUuid now currentUser reqDto =
  validateKmId reqDto $
  validatePackageId (reqDto ^. parentPackageId) $
  heGetOrganization $ \organization -> do
    let branch = fromChangeDTO reqDto bUuid (reqDto ^. parentPackageId) (Just $ currentUser ^. uuid) now now
    insertBranch branch
    insertEventsToBranch (U.toString $ branch ^. uuid) []
    updateKnowledgeModelByBranchId (U.toString $ branch ^. uuid) Nothing
    updateMigrationInfoIfParentPackageIdPresent branch
    createDefaultEventIfParentPackageIsNotPresent branch
    heRecompileKnowledgeModel (U.toString $ branch ^. uuid) $ \km -> return . Right $ toDTO branch organization
  where
    validateKmId reqDto callback = do
      let bKmId = reqDto ^. kmId
      case isValidKmId bKmId of
        Nothing -> do
          eitherBranchFromDb <- findBranchByKmId bKmId
          case eitherBranchFromDb of
            Right _ -> return . Left $ createErrorWithFieldError ("kmId", _ERROR_VALIDATION__KM_ID_UNIQUENESS bKmId)
            Left (NotExistsError _) -> callback
        Just error -> return . Left $ error
    validatePackageId mPackageId callback =
      case mPackageId of
        Just packageId -> do
          eitherPackage <- findPackageById packageId
          case eitherPackage of
            Right _ -> callback
            Left error ->
              return . Left $ createErrorWithFieldError ("parentPackageId", _ERROR_VALIDATION__PARENT_PKG_ABSENCE)
        Nothing -> callback
    updateMigrationInfoIfParentPackageIdPresent branch = do
      let branchUuid = U.toString $ branch ^. uuid
      let maybeParentPackageId = branch ^. parentPackageId
      case maybeParentPackageId of
        Just parentPackageId -> updateBranchWithMigrationInfo branchUuid parentPackageId parentPackageId
        Nothing -> return ()
    createDefaultEventIfParentPackageIsNotPresent branch = do
      let branchUuid = U.toString $ branch ^. uuid
      let maybeParentPackageId = branch ^. parentPackageId
      case maybeParentPackageId of
        Just _ -> return ()
        Nothing -> do
          uuid <- liftIO generateUuid
          kmUuid <- liftIO generateUuid
          let addKMEvent =
                AddKnowledgeModelEvent
                { _addKnowledgeModelEventUuid = uuid
                , _addKnowledgeModelEventPath = []
                , _addKnowledgeModelEventKmUuid = kmUuid
                , _addKnowledgeModelEventName = "New knowledge model"
                }
          insertEventsToBranch branchUuid [AddKnowledgeModelEvent' addKMEvent]

getBranchById :: String -> AppContextM (Either AppError BranchWithStateDTO)
getBranchById branchUuid =
  heGetOrganization $ \organization ->
    heFindBranchById branchUuid $ \branch -> do
      heGetBranchState (U.toString $ branch ^. uuid) $ \branchState ->
        return . Right $ toWithStateDTO branch branchState organization

modifyBranch :: String -> BranchChangeDTO -> AppContextM (Either AppError BranchDTO)
modifyBranch branchUuid reqDto =
  heGetOrganization $ \organization ->
    heFindBranchById branchUuid $ \branchFromDB ->
      validateKmId $
      validatePackageId (reqDto ^. parentPackageId) $ do
        now <- liftIO getCurrentTime
        let branch =
              fromChangeDTO
                reqDto
                (branchFromDB ^. uuid)
                (reqDto ^. parentPackageId)
                (branchFromDB ^. ownerUuid)
                (branchFromDB ^. createdAt)
                now
        updateBranchById branch
        return . Right $ toDTO branch organization
  where
    validateKmId callback = do
      let bKmId = reqDto ^. kmId
      case isValidKmId bKmId of
        Nothing -> do
          heFindBranchById branchUuid $ \branch -> do
            eitherBranchFromDb <- findBranchByKmId bKmId
            if isAlreadyUsedAndIsNotMine eitherBranchFromDb
              then return . Left . createErrorWithFieldError $ ("kmId", _ERROR_VALIDATION__KM_ID_UNIQUENESS bKmId)
              else callback
        Just error -> return . Left $ error
    validatePackageId mPackageId callback =
      case mPackageId of
        Just packageId -> do
          eitherPackage <- findPackageById packageId
          case eitherPackage of
            Right _ -> callback
            Left error ->
              return . Left $ createErrorWithFieldError ("parentPackageId", _ERROR_VALIDATION__PARENT_PKG_ABSENCE)
        Nothing -> callback
    isAlreadyUsedAndIsNotMine (Right branch) = U.toString (branch ^. uuid) /= branchUuid
    isAlreadyUsedAndIsNotMine (Left _) = False

deleteBranch :: String -> AppContextM (Maybe AppError)
deleteBranch branchUuid =
  hmFindBranchById branchUuid $ \branch -> do
    deleteBranchById branchUuid
    deleteMigratorStateByBranchUuid branchUuid
    return Nothing

getBranchState :: String -> AppContextM (Either AppError BranchState)
getBranchState branchUuid =
  getIsMigrating $ \isMigrating ->
    if isMigrating
      then return . Right $ BSMigrating
      else heFindBranchWithEventsById branchUuid $ \branch ->
             if isEditing branch
               then return . Right $ BSEdited
               else getIsMigrated $ \isMigrated ->
                      if isMigrated
                        then return . Right $ BSMigrated
                        else getIsOutdated branch $ \isOutdated ->
                               if isOutdated
                                 then return . Right $ BSOutdated
                                 else return . Right $ BSDefault
  where
    getIsMigrating callback = do
      eitherMs <- findMigratorStateByBranchUuid branchUuid
      case eitherMs of
        Right ms ->
          if ms ^. migrationState == CompletedState
            then callback False
            else callback True
        Left (NotExistsError _) -> callback False
        Left error -> return . Left $ error
    isEditing branch = Prelude.length (branch ^. events) > 0
    getIsOutdated branch callback =
      case branch ^. lastAppliedParentPackageId of
        Just lastAppliedParentPackageId ->
          heGetNewerPackages lastAppliedParentPackageId $ \newerPackages -> callback $ Prelude.length newerPackages > 0
        Nothing -> callback False
    getIsMigrated callback = do
      eitherMs <- findMigratorStateByBranchUuid branchUuid
      case eitherMs of
        Right ms ->
          if ms ^. migrationState == CompletedState
            then callback True
            else callback False
        Left (NotExistsError _) -> callback False
        Left error -> return . Left $ error

-- --------------------------------
-- HELPERS
-- --------------------------------
heGetBranchById branchUuid callback = do
  eitherBranch <- getBranchById branchUuid
  case eitherBranch of
    Right branch -> callback branch
    Left error -> return . Left $ error

hmGetBranchById branchUuid callback = do
  eitherBranch <- getBranchById branchUuid
  case eitherBranch of
    Right branch -> callback branch
    Left error -> return . Just $ error

-- -----------------------------------------------------
heGetBranchState branchUuid callback = do
  eitherBranchState <- getBranchState branchUuid
  case eitherBranchState of
    Right branchState -> callback branchState
    Left error -> return . Left $ error
