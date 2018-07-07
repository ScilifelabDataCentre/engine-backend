module Specs.API.Feedback.List_GET
  ( list_get
  ) where

import Data.Aeson (encode)
import Network.HTTP.Types
import Network.Wai (Application)
import Test.Hspec
import Test.Hspec.Wai hiding (shouldRespondWith)
import Test.Hspec.Wai.Matcher

import Database.Migration.Feedback.Data.Feedbacks
import qualified Database.Migration.Feedback.FeedbackMigration as F
import Model.Context.AppContext
import Service.Feedback.FeedbackMapper

import Specs.API.Common
import Specs.Common

-- ------------------------------------------------------------------------
-- GET /feedbacks
-- ------------------------------------------------------------------------
list_get :: AppContext -> SpecWith Application
list_get appContext = describe "GET /feedbacks" $ do test_200 appContext

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
reqMethod = methodGet

reqUrl = "/feedbacks"

reqHeaders = []

reqBody = ""

-- ----------------------------------------------------
-- ----------------------------------------------------
-- ----------------------------------------------------
test_200 appContext =
  it "HTTP 200 OK" $
     -- GIVEN: Prepare expectation
   do
    let expStatus = 200
    let expHeaders = [resCtHeader] ++ resCorsHeaders
    let expDto = [toDTO feedback1, toDTO feedback2]
    let expBody = encode expDto
     -- AND: Run migrations
    runInContextIO F.runMigration appContext
     -- WHEN: Call API
    response <- request reqMethod reqUrl reqHeaders reqBody
     -- AND: Compare response with expetation
    let responseMatcher =
          ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
    response `shouldRespondWith` responseMatcher
