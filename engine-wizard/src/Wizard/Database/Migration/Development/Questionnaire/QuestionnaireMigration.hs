module Wizard.Database.Migration.Development.Questionnaire.QuestionnaireMigration where

import Wizard.Constant.Component
import Wizard.Database.DAO.Package.PackageDAO
import Wizard.Database.DAO.Questionnaire.QuestionnaireDAO
import Wizard.Database.Migration.Development.Package.Data.Packages
import Wizard.Database.Migration.Development.Questionnaire.Data.Questionnaires
import Wizard.Util.Logger

runMigration = do
  logInfo $ msg _CMP_MIGRATION "(Questionnaire/Questionnaire) started"
  deleteQuestionnaires
  insertPackage germanyPackage
  insertQuestionnaire questionnaire1
  insertQuestionnaire questionnaire2
  insertQuestionnaire questionnaire3
  logInfo $ msg _CMP_MIGRATION "(Questionnaire/Questionnaire) ended"
