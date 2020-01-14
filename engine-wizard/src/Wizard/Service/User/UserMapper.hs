module Wizard.Service.User.UserMapper where

import Control.Lens ((^.))
import Data.Char (toLower)
import Data.Time
import qualified Data.UUID as U

import LensesConfig
import Wizard.Api.Resource.User.UserChangeDTO
import Wizard.Api.Resource.User.UserCreateDTO
import Wizard.Api.Resource.User.UserDTO
import Wizard.Api.Resource.User.UserProfileChangeDTO
import Wizard.Model.User.User

toDTO :: User -> UserDTO
toDTO user =
  UserDTO
    { _userDTOUuid = user ^. uuid
    , _userDTOName = user ^. name
    , _userDTOSurname = user ^. surname
    , _userDTOEmail = user ^. email
    , _userDTORole = user ^. role
    , _userDTOPermissions = user ^. permissions
    , _userDTOActive = user ^. active
    , _userDTOCreatedAt = user ^. createdAt
    , _userDTOUpdatedAt = user ^. updatedAt
    }

fromUserCreateDTO :: UserCreateDTO -> U.UUID -> String -> Role -> [Permission] -> UTCTime -> UTCTime -> User
fromUserCreateDTO dto userUuid passwordHash role permissions createdAt updatedAt =
  User
    { _userUuid = userUuid
    , _userName = dto ^. name
    , _userSurname = dto ^. surname
    , _userEmail = toLower <$> dto ^. email
    , _userPasswordHash = passwordHash
    , _userRole = role
    , _userPermissions = permissions
    , _userActive = False
    , _userCreatedAt = Just createdAt
    , _userUpdatedAt = Just updatedAt
    }

fromUserChangeDTO :: UserChangeDTO -> User -> [Permission] -> User
fromUserChangeDTO dto oldUser permission =
  User
    { _userUuid = oldUser ^. uuid
    , _userName = dto ^. name
    , _userSurname = dto ^. surname
    , _userEmail = toLower <$> dto ^. email
    , _userPasswordHash = oldUser ^. passwordHash
    , _userRole = dto ^. role
    , _userPermissions = permission
    , _userActive = dto ^. active
    , _userCreatedAt = oldUser ^. createdAt
    , _userUpdatedAt = oldUser ^. updatedAt
    }

fromUserProfileChangeDTO :: UserProfileChangeDTO -> User -> User
fromUserProfileChangeDTO dto oldUser =
  User
    { _userUuid = oldUser ^. uuid
    , _userName = dto ^. name
    , _userSurname = dto ^. surname
    , _userEmail = toLower <$> dto ^. email
    , _userPasswordHash = oldUser ^. passwordHash
    , _userRole = oldUser ^. role
    , _userPermissions = oldUser ^. permissions
    , _userActive = oldUser ^. active
    , _userCreatedAt = oldUser ^. createdAt
    , _userUpdatedAt = oldUser ^. updatedAt
    }
