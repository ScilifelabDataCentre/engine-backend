module Registry.Service.Config.BuildInfoConfigService where

import Data.Yaml (decodeFileEither)

import Registry.Model.Config.BuildInfoConfig
import Registry.Model.Config.BuildInfoConfigJM ()
import Shared.Model.Error.Error

getBuildInfoConfig :: String -> IO (Either AppError BuildInfoConfig)
getBuildInfoConfig fileName = do
  eConfig <- decodeFileEither fileName
  case eConfig of
    Right config -> return . Right $ config
    Left error -> return . Left . GeneralServerError . show $ error
