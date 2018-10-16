module Field exposing
    ( Field(..)
    , Msg
    , clearError
    , decoder
    , isEmpty
    , name
    , order
    , submit
    , update
    , view
    )

{-| Notice that the functions inside this
module include view, update, and Msg, just
like the classic values in TEA.

This form architecture treats each field as a
tiny sub-application with the same structure
as the entire program

-}

import Data.Check as Check exposing (Check)
import Data.Submission as Submission exposing (Submission)
import Field.Select as Select
import Field.Text as Text
import Html.Styled as Html exposing (Html)
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline
import Json.Encode as E



-- TYPES --


{-| These are the two field types
in this program. If you would like
more field types its clearly scalable:
just make a new module Field/X.elm, with
its own view, update, Model, Msg, validate,
isEmpty, and submit values.

Other plausible Field types that would
warrant their own field module:

  - check box
  - address
  - password

-}
type Field
    = Text Text.Model
    | Select Select.Model


type Msg
    = TextMsg Text.Msg
    | SelectMsg Select.Msg


order : Field -> Int
order field =
    case field of
        Text model ->
            Text.order model

        Select model ->
            Select.order model


name : Field -> String
name field =
    case field of
        Text model ->
            Text.name model

        Select model ->
            Select.name model



-- VALIDATION --


isEmpty : Field -> Bool
isEmpty field =
    case field of
        Text model ->
            Text.isEmpty model

        Select model ->
            Select.isEmpty model


clearError : Field -> Field
clearError field =
    case field of
        Text model ->
            Text (clearErrorHelper model)

        Select model ->
            Select (Select.clearError model)


clearErrorHelper : { a | error : Maybe e } -> { a | error : Maybe e }
clearErrorHelper field =
    { field | error = Nothing }



-- SUBMIT --


submit : Field -> Submission Field
submit field =
    case field of
        Text model ->
            model
                |> Text.submit
                |> Submission.mapField Text

        Select model ->
            model
                |> Select.submit
                |> Submission.mapField Select



-- UPDATE --


update : Msg -> Field -> Field
update msg field =
    case msg of
        TextMsg subMsg ->
            mapText (Text.update subMsg) field

        SelectMsg subMsg ->
            mapSelect (Select.update subMsg) field



-- VIEW --


view : Field -> Html Msg
view field =
    case field of
        Text textModel ->
            Html.map TextMsg (Text.view textModel)

        Select selectModel ->
            Html.map SelectMsg (Select.view selectModel)



-- HELPERS --


mapText : (Text.Model -> Text.Model) -> Field -> Field
mapText f field =
    case field of
        Text model ->
            Text (f model)

        _ ->
            field


mapSelect : (Select.Model -> Select.Model) -> Field -> Field
mapSelect f field =
    case field of
        Select model ->
            Select (f model)

        _ ->
            field



-- DECODER --


decoder : Decoder Field
decoder =
    D.string
        |> D.field "type"
        |> D.andThen decoderFromType


decoderFromType : String -> Decoder Field
decoderFromType type_ =
    case type_ of
        "text" ->
            Text.decoder
                |> D.map Text

        "select" ->
            Select.decoder
                |> D.map Select

        _ ->
            D.fail "Unrecognized form type"
