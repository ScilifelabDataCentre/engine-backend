module Wizard.Service.Config.IntegrationConfigService
  ( getIntegrationConfig
  -- Helpers
  , heGetIntegrationConfig
  ) where

import Control.Lens ((^.))
import Control.Monad.Reader (asks, liftIO)
import Data.Map.Strict as M
import Data.Maybe (fromMaybe)
import Data.Yaml (decodeFileEither)

import LensesConfig hiding (items)
import Shared.Model.Error.Error
import Wizard.Constant.Component
import Wizard.Model.Context.AppContext
import Wizard.Util.Logger (logWarnU, msg)

getIntegrationConfig :: String -> AppContextM (Either AppError (M.Map String String))
getIntegrationConfig sectionName = do
  appConfig <- asks _appContextApplicationConfig
  let integrationConfigPath = appConfig ^. general . integrationConfig
  eIntConfig <- liftIO $ decodeFileEither integrationConfigPath
  case eIntConfig of
    Right intConfig -> return . Right . fromMaybe M.empty . M.lookup sectionName $ intConfig
    Left error -> do
      logWarnU $ msg _CMP_SERVICE ("Failed to load integration configuration (error: " ++ show error ++ ")")
      return . Right $ M.empty

-- --------------------------------
-- HELPERS
-- --------------------------------
heGetIntegrationConfig sectionName callback = do
  eitherResult <- getIntegrationConfig sectionName
  case eitherResult of
    Right result -> callback result
    Left error -> return . Left $ error
