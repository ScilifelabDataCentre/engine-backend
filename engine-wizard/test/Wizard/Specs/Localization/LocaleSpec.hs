module Wizard.Specs.Localization.LocaleSpec where

import Test.Hspec hiding (shouldBe)
import Test.Hspec.Expectations.Pretty

import Shared.Localization.Locale

localeSpec =
  describe "LocalizationExpander" $
  describe "format" $ do
    createTest "My String" [] "My String"
    createTest "My %s String" ["Super"] "My Super String"
    createTest "My String %s" ["Super"] "My String Super"
    createTest "%s My String" ["Super"] "Super My String"
    createTest "My %%s String" ["Super"] "My %s String"
    createTest "My %s String" [] "My %s String"
    createTest "My %s String %s %s" ["Super", "abc", "123"] "My Super String abc 123"
    createTest "My %s String %s %s" ["Super", "abc"] "My Super String abc %s"

createTest template variables expected =
  it ("Expand '" ++ template ++ "' with variables " ++ (show variables) ++ " to '" ++ expected ++ "'") $
  format template variables `shouldBe` expected
