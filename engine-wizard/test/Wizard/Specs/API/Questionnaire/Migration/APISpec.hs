module Wizard.Specs.API.Questionnaire.Migration.APISpec where

import Test.Hspec
import Test.Hspec.Wai hiding (shouldRespondWith)

import Wizard.Specs.API.Common
import Wizard.Specs.API.Questionnaire.Migration.Current_DELETE
import Wizard.Specs.API.Questionnaire.Migration.Current_GET
import Wizard.Specs.API.Questionnaire.Migration.Current_PUT
import Wizard.Specs.API.Questionnaire.Migration.List_POST

questionnaireMigrationAPI appContext =
  with (startWebApp appContext) $
  describe "QUESTIONNAIRE MIGRATION API Spec" $ do
    list_post appContext
    current_get appContext
    current_put appContext
    current_delete appContext
