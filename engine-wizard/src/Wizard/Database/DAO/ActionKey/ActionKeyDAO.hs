module Wizard.Database.DAO.ActionKey.ActionKeyDAO where

import Data.Bson

import Shared.Model.Error.Error
import Wizard.Database.BSON.ActionKey.ActionKey ()
import Wizard.Database.DAO.Common
import Wizard.Model.ActionKey.ActionKey
import Wizard.Model.Context.AppContext

entityName = "actionKey"

collection = "actionKeys"

findActionKeys :: AppContextM (Either AppError [ActionKey])
findActionKeys = createFindEntitiesFn collection

findActionKeyById :: String -> AppContextM (Either AppError ActionKey)
findActionKeyById = createFindEntityByFn collection entityName "uuid"

findActionKeyByHash :: String -> AppContextM (Either AppError ActionKey)
findActionKeyByHash = createFindEntityByFn collection entityName "hash"

insertActionKey :: ActionKey -> AppContextM Value
insertActionKey = createInsertFn collection

deleteActionKeys :: AppContextM ()
deleteActionKeys = createDeleteEntitiesFn collection

deleteActionKeyById :: String -> AppContextM ()
deleteActionKeyById = createDeleteEntityByFn collection "uuid"

deleteActionKeyByHash :: String -> AppContextM ()
deleteActionKeyByHash = createDeleteEntityByFn collection "hash"
