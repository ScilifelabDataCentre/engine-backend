module Wizard.Api.Resource.User.UserStateJM where

import Data.Aeson

import Wizard.Api.Resource.User.UserStateDTO
import Wizard.Util.JSON (simpleParseJSON, simpleToJSON)

instance FromJSON UserStateDTO where
  parseJSON = simpleParseJSON "_userStateDTO"

instance ToJSON UserStateDTO where
  toJSON = simpleToJSON "_userStateDTO"
