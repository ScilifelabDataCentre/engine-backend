module Database.Migration.Migration where

import Common.Context
import qualified Database.Migration.Branch.BranchMigration as BM
import qualified
       Database.Migration.Organization.OrganizationMigration as ORG
import qualified Database.Migration.Package.PackageMigration as PKG
import qualified Database.Migration.User.UserMigration as UM
import qualified Database.Migration.Migrator.MigratorMigration as MM

logState = putStrLn

runMigration context dspConfig = do
  logState "MIGRATION: started"
  ORG.runMigration context dspConfig logState
  UM.runMigration context dspConfig logState
  PKG.runMigration context dspConfig logState
  BM.runMigration context dspConfig logState
  MM.runMigration context dspConfig logState
  logState "MIGRATION: ended"
