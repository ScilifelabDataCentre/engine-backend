module Wizard.Api.Handler.Package.PackageHandler where

import Network.HTTP.Types.Status (created201, noContent204)
import Web.Scotty.Trans (body, json, param, status)

import Wizard.Api.Handler.Common
import Wizard.Api.Resource.Package.PackageDetailJM ()
import Wizard.Api.Resource.Package.PackageSimpleJM ()
import Wizard.Service.Package.PackageService
import Wizard.Service.PackageBundle.PackageBundleService

getPackagesA :: Endpoint
getPackagesA =
  checkPermission "PM_READ_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    queryParams <- getListOfQueryParamsIfPresent ["organizationId", "kmId"]
    eitherResDtos <- runInAuthService $ getSimplePackagesFiltered queryParams
    case eitherResDtos of
      Right resDtos -> json resDtos
      Left error -> sendError error

postPackagesA :: Endpoint
postPackagesA =
  checkPermission "PM_WRITE_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    reqBody <- body
    eitherDto <- runInAuthService $ importAndConvertPackageBundle reqBody
    case eitherDto of
      Right dto -> do
        status created201
        json dto
      Left error -> sendError error

getPackageA :: Endpoint
getPackageA =
  checkPermission "PM_READ_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    pkgId <- param "pkgId"
    eitherResDto <- runInAuthService $ getPackageById pkgId
    case eitherResDto of
      Right resDto -> json resDto
      Left error -> sendError error

deletePackagesA :: Endpoint
deletePackagesA =
  checkPermission "PM_WRITE_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    queryParams <- getListOfQueryParamsIfPresent ["organizationId", "kmId"]
    maybeError <- runInAuthService $ deletePackagesByQueryParams queryParams
    case maybeError of
      Nothing -> status noContent204
      Just error -> sendError error

deletePackageA :: Endpoint
deletePackageA =
  checkPermission "PM_WRITE_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    pkgId <- param "pkgId"
    maybeError <- runInAuthService $ deletePackage pkgId
    case maybeError of
      Nothing -> status noContent204
      Just error -> sendError error

postPackagePullA :: Endpoint
postPackagePullA =
  checkPermission "PM_WRITE_PERM" $
  getAuthServiceExecutor $ \runInAuthService -> do
    pkgId <- param "pkgId"
    maybeError <- runInAuthService $ pullPackageBundleFromRegistry pkgId
    case maybeError of
      Nothing -> status noContent204
      Just error -> sendError error
