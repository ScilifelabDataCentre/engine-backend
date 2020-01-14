module Wizard.Service.BookReference.BookReferenceMapper where

import Control.Lens ((^.))

import LensesConfig
import Wizard.Api.Resource.BookReference.BookReferenceDTO
import Wizard.Model.BookReference.BookReference

toDTO :: BookReference -> BookReferenceDTO
toDTO br =
  BookReferenceDTO
    { _bookReferenceDTOShortUuid = br ^. shortUuid
    , _bookReferenceDTOBookChapter = br ^. bookChapter
    , _bookReferenceDTOContent = br ^. content
    , _bookReferenceDTOCreatedAt = br ^. createdAt
    , _bookReferenceDTOUpdatedAt = br ^. updatedAt
    }

fromDTO :: BookReferenceDTO -> BookReference
fromDTO dto =
  BookReference
    { _bookReferenceShortUuid = dto ^. shortUuid
    , _bookReferenceBookChapter = dto ^. bookChapter
    , _bookReferenceContent = dto ^. content
    , _bookReferenceCreatedAt = dto ^. createdAt
    , _bookReferenceUpdatedAt = dto ^. updatedAt
    }
