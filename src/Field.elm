module Field exposing
    ( Field(..)
    , Msg
    , clearError
    , isEmpty
    , isValid
    , submit
    , throwError
    , update
    , view
    )

import Data.Submission as Submission exposing (Submission)
import Field.Select as Select
import Field.Text as Text
import Html.Styled as Html exposing (Html)
import Json.Encode as E



-- TYPES --


type Field
    = Text Text.Model
    | Select Select.Model


type Msg
    = TextMsg Text.Msg
    | SelectMsg Select.Msg



-- VALIDATION --


isEmpty : Field -> Bool
isEmpty field =
    case field of
        Text model ->
            Text.isEmpty model

        Select model ->
            Select.isEmpty model


isValid : Field -> Bool
isValid field =
    case field of
        Text model ->
            isValidHelper model

        Select model ->
            isValidHelper model


isValidHelper : { a | error : Maybe e } -> Bool
isValidHelper { error } =
    error == Nothing


throwError : Field -> Field
throwError field =
    case field of
        Text model ->
            Text (Text.throwError model)

        Select model ->
            Select (Select.throwError model)


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
