module Specs.API.TokenAPISpec where

import Control.Lens
import Data.Aeson
import Data.Aeson (Value(..), object, (.=))
import Data.ByteString.Lazy
import Data.Foldable
import Data.Maybe
import qualified Data.UUID as U
import Network.HTTP.Types
import Network.Wai (Application)
import Network.Wai.Test hiding (request)
import Test.Hspec
import qualified Test.Hspec.Expectations.Pretty as TP
import Test.Hspec.Wai hiding (shouldRespondWith)
import qualified Test.Hspec.Wai.JSON as HJ
import Test.Hspec.Wai.Matcher
import qualified Web.Scotty as S

import Api.Resources.Token.TokenCreateDTO
import Api.Resources.Token.TokenDTO
import Common.Error

import Specs.API.Common

tokenAPI context dspConfig =
  with (startWebApp context dspConfig) $ do
    describe "TOKEN API Spec" $
      -- ------------------------------------------------------------------------
      -- POST /tokens
      -- ------------------------------------------------------------------------
      describe "POST /tokens" $ do
        let reqMethod = methodPost
        let reqUrl = "/tokens"
        it "HTTP 201 OK" $
          -- GIVEN: Prepare request
         do
          let reqHeaders = [reqAuthHeader, reqCtHeader]
          let reqDto = TokenCreateDTO {_tcdtoEmail = "darth.vader@deathstar.com", _tcdtoPassword = "password"}
          let reqBody = encode reqDto
          -- GIVEN: Prepare expectation
          let expStatus = 201
          let expHeaders = [resCtHeader] ++ resCorsHeaders
          let expDto =
                TokenDTO
                { _tdtoToken =
                    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyVXVpZCI6ImVjNmY4ZTkwLTJhOTEtNDllYy1hYTNmLTllYWIyMjY3ZmM2NiIsInBlcm1pc3Npb25zIjpbIlVNX1BFUk0iLCJPUkdfUEVSTSIsIktNX1BFUk0iLCJLTV9VUEdBREVfUEVSTSIsIktNX1BVQkxJU0hfUEVSTSIsIlBNX1BFUk0iLCJXSVpfUEVSTSIsIkRNUF9QRVJNIl19.uXOhszvkNi7BKMqVMAQMlTK3BAfhfD58Zdiwiz_U1Z8"
                }
          let expBody = encode expDto
          -- WHEN: Call API
          response <- request reqMethod reqUrl reqHeaders reqBody
          -- AND: Compare response with expetation
          let responseMatcher =
                ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
          response `shouldRespondWith` responseMatcher
        createInvalidJsonTest reqMethod reqUrl [HJ.json| { email: "darth.vader@deathstar.com" } |] "password"
        it "HTTP 401 UNAUTHORIZED when email or password are not valid" $
          -- GIVEN: Prepare request
         do
          let reqHeaders = [reqAuthHeader, reqCtHeader]
          let reqDto = TokenCreateDTO {_tcdtoEmail = "darth.vader@deathstar.com2", _tcdtoPassword = "password"}
          let reqBody = encode reqDto
          -- GIVEN: Prepare expectation
          let expStatus = 401
          let expHeaders = [resCtHeader] ++ resCorsHeaders
          let expBody =
                [HJ.json|
              {
                status: 401,
                error: "Unauthorized"
              }
              |]
          -- WHEN: Call API
          response <- request reqMethod reqUrl reqHeaders reqBody
          -- AND: Compare response with expetation
          let responseMatcher =
                ResponseMatcher {matchHeaders = expHeaders, matchStatus = expStatus, matchBody = bodyEquals expBody}
          response `shouldRespondWith` responseMatcher