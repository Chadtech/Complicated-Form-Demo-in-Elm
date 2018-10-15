module Msg exposing (Msg(..))

import Field
import Json.Decode as D exposing (Decoder, Value)
import Page exposing (Page(..))


type Msg
    = FieldMsg String Field.Msg
    | NavButtonClicked Page
    | SubmitClicked
