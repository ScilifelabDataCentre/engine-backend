module Wizard.Api.Resource.Event.IntegrationEventJM where

import Data.Aeson

import Wizard.Api.Resource.Event.EventFieldJM ()
import Wizard.Api.Resource.Event.IntegrationEventDTO
import Wizard.Util.JSON (simpleParseJSON, simpleToJSON')

instance FromJSON AddIntegrationEventDTO where
  parseJSON = simpleParseJSON "_addIntegrationEventDTO"

instance ToJSON AddIntegrationEventDTO where
  toJSON = simpleToJSON' "eventType" "_addIntegrationEventDTO"

-- --------------------------------------------
instance FromJSON EditIntegrationEventDTO where
  parseJSON = simpleParseJSON "_editIntegrationEventDTO"

instance ToJSON EditIntegrationEventDTO where
  toJSON = simpleToJSON' "eventType" "_editIntegrationEventDTO"

-- --------------------------------------------
instance FromJSON DeleteIntegrationEventDTO where
  parseJSON = simpleParseJSON "_deleteIntegrationEventDTO"

instance ToJSON DeleteIntegrationEventDTO where
  toJSON = simpleToJSON' "eventType" "_deleteIntegrationEventDTO"
