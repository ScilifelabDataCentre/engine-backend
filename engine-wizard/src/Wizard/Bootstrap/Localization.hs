module Wizard.Bootstrap.Localization
  ( loadLocalization
  ) where

import Control.Lens ((^.), (^?))
import Control.Monad.Reader (liftIO)
import Data.Aeson (eitherDecode)
import Data.Aeson.Lens (_Value)
import qualified Data.Map.Strict as M
import Network.Wreq (get, responseBody)

import LensesConfig hiding (headers)
import Shared.Model.Error.Error
import Shared.Service.File.FileService
import Wizard.Constant.Component
import Wizard.Constant.Resource
import Wizard.Util.Logger (logError, logInfo, msg)

loadLocalization appConfig = do
  logInfo $ msg _CMP_LOCALIZATION "start loading localization"
  localLocalization <- loadLocalLocalization appConfig
  remoteLocalization <- loadRemoteLocalization appConfig
  logInfo $ msg _CMP_LOCALIZATION "localization loaded"
  return $ M.union remoteLocalization localLocalization

loadLocalLocalization appConfig = do
  logInfo $ msg _CMP_LOCALIZATION "start loading local localization"
  eResult <- liftIO (loadJSONFile localizationFile :: IO (Either AppError (M.Map String String)))
  case eResult of
    Right result -> do
      logInfo . show $ result
      logInfo $ msg _CMP_LOCALIZATION "local localization loaded"
      return result
    Left error -> do
      logError $ msg _CMP_LOCALIZATION "load failed"
      logError $
        msg
          _CMP_LOCALIZATION
          ("can't load '" ++ localizationFile ++ "'. Maybe the file is missing or not well-formatted")
      logError $ msg _CMP_LOCALIZATION (show error)
      return M.empty

loadRemoteLocalization appConfig = do
  logInfo $ msg _CMP_LOCALIZATION "start loading remote localization"
  let mUrl = appConfig ^. general . remoteLocalizationUrl
  case mUrl of
    Just url -> do
      response <- liftIO $ get url
      case response ^? responseBody . _Value of
        Just body ->
          case eitherDecode $ response ^. responseBody of
            Right body -> do
              logInfo $ msg _CMP_LOCALIZATION "remote localization loaded"
              return body
            Left error -> do
              logError $ msg _CMP_LOCALIZATION "server couln't deserialized response from localization server"
              return M.empty
        Nothing -> do
          logError $ msg _CMP_LOCALIZATION "server couln't retrieved response from localization server"
          return M.empty
    Nothing -> do
      logInfo $ msg _CMP_LOCALIZATION "there is no configured remote localization"
      return M.empty
