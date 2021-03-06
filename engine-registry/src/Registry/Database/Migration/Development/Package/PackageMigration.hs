module Registry.Database.Migration.Development.Package.PackageMigration where

import Registry.Constant.Component
import Registry.Database.DAO.Package.PackageDAO
import Registry.Database.Migration.Development.Package.Data.Packages
import Registry.Util.Logger

runMigration = do
  logInfo $ msg _CMP_MIGRATION "(Package/Package) started"
  deletePackages
  insertPackage globalPackageEmpty
  insertPackage globalPackage
  insertPackage netherlandsPackage
  insertPackage netherlandsPackageV2
  logInfo $ msg _CMP_MIGRATION "(Package/Package) ended"
