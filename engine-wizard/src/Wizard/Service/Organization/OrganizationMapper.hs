module Wizard.Service.Organization.OrganizationMapper where

import Control.Lens ((^.))
import Data.Time

import LensesConfig
import Wizard.Api.Resource.Organization.OrganizationChangeDTO
import Wizard.Api.Resource.Organization.OrganizationDTO
import Wizard.Api.Resource.Organization.OrganizationSimpleDTO
import Wizard.Integration.Resource.Organization.OrganizationSimpleIDTO
import Wizard.Model.Organization.Organization

toDTO :: Organization -> OrganizationDTO
toDTO organization =
  OrganizationDTO
    { _organizationDTOUuid = organization ^. uuid
    , _organizationDTOName = organization ^. name
    , _organizationDTOOrganizationId = organization ^. organizationId
    , _organizationDTOCreatedAt = organization ^. createdAt
    , _organizationDTOUpdatedAt = organization ^. updatedAt
    }

toSimpleDTO :: Organization -> OrganizationSimpleDTO
toSimpleDTO organization =
  OrganizationSimpleDTO
    { _organizationSimpleDTOName = organization ^. name
    , _organizationSimpleDTOOrganizationId = organization ^. organizationId
    , _organizationSimpleDTOLogo = Nothing
    }

fromDTO :: OrganizationChangeDTO -> UTCTime -> UTCTime -> Organization
fromDTO dto orgCreatedAt orgUpdatedAt =
  Organization
    { _organizationUuid = dto ^. uuid
    , _organizationName = dto ^. name
    , _organizationOrganizationId = dto ^. organizationId
    , _organizationCreatedAt = orgCreatedAt
    , _organizationUpdatedAt = orgUpdatedAt
    }

fromSimpleIntegration :: OrganizationSimpleIDTO -> OrganizationSimpleDTO
fromSimpleIntegration org =
  OrganizationSimpleDTO
    { _organizationSimpleDTOName = org ^. name
    , _organizationSimpleDTOOrganizationId = org ^. organizationId
    , _organizationSimpleDTOLogo = org ^. logo
    }
