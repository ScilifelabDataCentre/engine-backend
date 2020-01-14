module Wizard.Service.Migration.Questionnaire.MigratorMapper where

import Control.Lens ((^.))
import qualified Data.UUID as U

import LensesConfig
import Wizard.Api.Resource.Migration.Questionnaire.MigratorStateChangeDTO
import Wizard.Api.Resource.Migration.Questionnaire.MigratorStateDTO
import Wizard.Api.Resource.Questionnaire.QuestionnaireDetailDTO
import Wizard.Model.Migration.Questionnaire.MigratorState

toDTO :: QuestionnaireDetailDTO -> QuestionnaireDetailDTO -> [U.UUID] -> MigratorStateDTO
toDTO oldQtn newQtn qtnUuids =
  MigratorStateDTO
    { _migratorStateDTOOldQuestionnaire = oldQtn
    , _migratorStateDTONewQuestionnaire = newQtn
    , _migratorStateDTOResolvedQuestionUuids = qtnUuids
    }

fromCreateDTO :: U.UUID -> U.UUID -> MigratorState
fromCreateDTO oldQtnUuid newQtnUuid =
  MigratorState
    { _migratorStateOldQuestionnaireUuid = oldQtnUuid
    , _migratorStateNewQuestionnaireUuid = newQtnUuid
    , _migratorStateResolvedQuestionUuids = []
    }

fromChangeDTO :: MigratorStateChangeDTO -> MigratorStateDTO -> MigratorState
fromChangeDTO changeDto ms =
  MigratorState
    { _migratorStateOldQuestionnaireUuid = ms ^. oldQuestionnaire . uuid
    , _migratorStateNewQuestionnaireUuid = ms ^. newQuestionnaire . uuid
    , _migratorStateResolvedQuestionUuids = changeDto ^. resolvedQuestionUuids
    }
