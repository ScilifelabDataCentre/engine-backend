module Wizard.Api.Resource.Questionnaire.QuestionnaireJM where

import Data.Aeson

import Wizard.Api.Resource.Package.PackageSimpleJM ()
import Wizard.Api.Resource.Questionnaire.QuestionnaireAccessibilityJM ()
import Wizard.Api.Resource.Questionnaire.QuestionnaireDTO
import Wizard.Api.Resource.Questionnaire.QuestionnaireStateJM ()
import Wizard.Util.JSON (simpleParseJSON, simpleToJSON)

instance FromJSON QuestionnaireDTO where
  parseJSON = simpleParseJSON "_questionnaireDTO"

instance ToJSON QuestionnaireDTO where
  toJSON = simpleToJSON "_questionnaireDTO"
