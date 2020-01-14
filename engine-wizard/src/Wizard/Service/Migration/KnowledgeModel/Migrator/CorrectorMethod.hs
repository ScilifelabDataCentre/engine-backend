module Wizard.Service.Migration.KnowledgeModel.Migrator.CorrectorMethod
  ( runCorrectorMethod
  ) where

import Control.Lens

import LensesConfig
import Shared.Model.Event.Event
import Wizard.Model.Migration.KnowledgeModel.MigratorState
import Wizard.Service.Migration.KnowledgeModel.Migrator.Sanitizator

runCorrectorMethod :: MigratorState -> Event -> IO MigratorState
runCorrectorMethod state event = do
  sanitizedEvent <- sanitizeEvent state event
  return $ state & migrationState .~ (ConflictState . CorrectorConflict $ sanitizedEvent)

sanitizeEvent :: MigratorState -> Event -> IO Event
sanitizeEvent state (EditKnowledgeModelEvent' e) = sanitize state e >>= \e2 -> return . EditKnowledgeModelEvent' $ e2
sanitizeEvent state (EditChapterEvent' e) = sanitize state e >>= \e2 -> return . EditChapterEvent' $ e2
sanitizeEvent state (EditQuestionEvent' e) = sanitize state e >>= \e2 -> return . EditQuestionEvent' $ e2
sanitizeEvent state (EditAnswerEvent' e) = sanitize state e >>= \e2 -> return . EditAnswerEvent' $ e2
sanitizeEvent state event = return event
