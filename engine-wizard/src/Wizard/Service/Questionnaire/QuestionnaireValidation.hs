module Wizard.Service.Questionnaire.QuestionnaireValidation where

import Shared.Model.Error.Error
import Shared.Util.Helper (createHmmHelper)
import Wizard.Database.DAO.Migration.Questionnaire.MigratorDAO
import Wizard.Localization.Messages.Public
import Wizard.Model.Context.AppContext

validateQuestionnaireDeletation :: String -> AppContextM (Maybe AppError)
validateQuestionnaireDeletation qtnUuid = validateUsageByQtnMigration qtnUuid

validateUsageByQtnMigration :: String -> AppContextM (Maybe AppError)
validateUsageByQtnMigration qtnUuid = do
  eitherResult <- findMigratorStatesByOldQuestionnaireId qtnUuid
  case eitherResult of
    Right [] -> return Nothing
    Right _ -> return . Just . UserError $ _ERROR_SERVICE_QTN__QTN_CANT_BE_DELETED_BECAUSE_IT_IS_USED_IN_MIGRATION
    Left error -> return . Just $ error

-- --------------------------------
-- HELPERS
-- --------------------------------
hmValidateQuestionnaireDeletation qtnUuid callback = createHmmHelper (validateQuestionnaireDeletation qtnUuid) callback
