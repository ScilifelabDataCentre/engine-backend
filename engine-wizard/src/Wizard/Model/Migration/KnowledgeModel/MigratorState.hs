module Wizard.Model.Migration.KnowledgeModel.MigratorState where

import qualified Data.UUID as U
import GHC.Generics

import Shared.Model.Event.Event
import Shared.Model.KnowledgeModel.KnowledgeModel

data MigrationState
  = RunningState
  | ConflictState Conflict
  | ErrorState
  | CompletedState
  deriving (Show, Eq, Generic)

data Conflict =
  CorrectorConflict Event
  deriving (Show, Eq, Generic)

data MigrationConflictAction
  = MCAApply
  | MCAEdited
  | MCAReject
  deriving (Show, Eq, Generic)

data MigratorState =
  MigratorState
    { _migratorStateBranchUuid :: U.UUID
    , _migratorStateMetamodelVersion :: Int
    , _migratorStateMigrationState :: MigrationState
    , _migratorStateBranchPreviousPackageId :: String
    , _migratorStateTargetPackageId :: String
    , _migratorStateBranchEvents :: [Event]
    , _migratorStateTargetPackageEvents :: [Event]
    , _migratorStateResultEvents :: [Event]
    , _migratorStateCurrentKnowledgeModel :: Maybe KnowledgeModel
    }
  deriving (Show, Eq)
