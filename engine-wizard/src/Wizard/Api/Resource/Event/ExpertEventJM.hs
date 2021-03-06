module Wizard.Api.Resource.Event.ExpertEventJM where

import Data.Aeson

import Wizard.Api.Resource.Event.EventFieldJM ()
import Wizard.Api.Resource.Event.ExpertEventDTO
import Wizard.Util.JSON (simpleParseJSON, simpleToJSON')

instance FromJSON AddExpertEventDTO where
  parseJSON = simpleParseJSON "_addExpertEventDTO"

instance ToJSON AddExpertEventDTO where
  toJSON = simpleToJSON' "eventType" "_addExpertEventDTO"

instance FromJSON EditExpertEventDTO where
  parseJSON = simpleParseJSON "_editExpertEventDTO"

instance ToJSON EditExpertEventDTO where
  toJSON = simpleToJSON' "eventType" "_editExpertEventDTO"

instance FromJSON DeleteExpertEventDTO where
  parseJSON = simpleParseJSON "_deleteExpertEventDTO"

instance ToJSON DeleteExpertEventDTO where
  toJSON = simpleToJSON' "eventType" "_deleteExpertEventDTO"
