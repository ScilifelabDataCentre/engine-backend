module Wizard.Specs.Service.Package.PackageValidationSpec where

import Data.Maybe
import Test.Hspec

import Wizard.Service.Package.PackageValidation

packageValidationSpec =
  describe "Package Validation" $ do
    it "validatePackageIdFormat" $ do
      isNothing (validatePackageIdFormat "org.nl:core-nl:0.0.0") `shouldBe` True
      isJust (validatePackageIdFormat "") `shouldBe` True
      isJust (validatePackageIdFormat "0.0.0") `shouldBe` True
      isJust (validatePackageIdFormat ":0.0.0") `shouldBe` True
      isJust (validatePackageIdFormat "core-nl:0.0.0") `shouldBe` True
      isJust (validatePackageIdFormat ":core-nl:0.0.0") `shouldBe` True
      isJust (validatePackageIdFormat "org.nl::0.0.0") `shouldBe` True
      isJust (validatePackageIdFormat "org.nl:core-nl:") `shouldBe` True
      isJust (validatePackageIdFormat "org.nl:core-nl:1") `shouldBe` True
    it "validateVersionFormat" $ do
      isNothing (validateVersionFormat "0.0.0") `shouldBe` True
      isNothing (validateVersionFormat "1.2.0") `shouldBe` True
      isNothing (validateVersionFormat "10.10.10") `shouldBe` True
      isNothing (validateVersionFormat "100.100.100") `shouldBe` True
      isJust (validateVersionFormat "1") `shouldBe` True
      isJust (validateVersionFormat "1.") `shouldBe` True
      isJust (validateVersionFormat "1.2") `shouldBe` True
      isJust (validateVersionFormat "1.2.") `shouldBe` True
      isJust (validateVersionFormat "1.2.a") `shouldBe` True
      isJust (validateVersionFormat "1.2.3.4") `shouldBe` True
      isJust (validateVersionFormat "a.2.3.4") `shouldBe` True
      isJust (validateVersionFormat "a2.3.4") `shouldBe` True
      isJust (validateVersionFormat "a.3.4") `shouldBe` True
    it "validateIsVersionHigher" $ do
      isNothing (validateIsVersionHigher "0.0.1" "0.0.0") `shouldBe` True
      isNothing (validateIsVersionHigher "0.1.0" "0.0.0") `shouldBe` True
      isNothing (validateIsVersionHigher "0.1.1" "0.0.0") `shouldBe` True
      isNothing (validateIsVersionHigher "1.0.0" "0.0.0") `shouldBe` True
      isNothing (validateIsVersionHigher "1.2.4" "1.2.3") `shouldBe` True
      isJust (validateIsVersionHigher "0.0.0" "0.0.0") `shouldBe` True
      isJust (validateIsVersionHigher "1.0.0" "1.0.0") `shouldBe` True
      isJust (validateIsVersionHigher "0.1.0" "1.0.0") `shouldBe` True
      isJust (validateIsVersionHigher "0.0.1" "1.0.0") `shouldBe` True
    it "validatePackageIdWithCoordinates" $ do
      isNothing (validatePackageIdWithCoordinates "com:global:1.0.0" "com" "global" "1.0.0") `shouldBe` True
      isJust (validatePackageIdWithCoordinates "" "com" "global" "1.0.0") `shouldBe` True
      isJust (validatePackageIdWithCoordinates ":global:1.0.0" "com" "global" "1.0.0") `shouldBe` True
      isJust (validatePackageIdWithCoordinates "com::1.0.0" "com" "global" "1.0.0") `shouldBe` True
      isJust (validatePackageIdWithCoordinates "com:global:" "com" "global" "1.0.0") `shouldBe` True
      isJust (validatePackageIdWithCoordinates "com:global:1.1.0" "com" "global" "1.0.0") `shouldBe` True
      isJust (validatePackageIdWithCoordinates "com:global-2:1.1.0" "com" "global" "1.0.0") `shouldBe` True
