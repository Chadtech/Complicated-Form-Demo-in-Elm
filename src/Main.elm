module Main exposing (main)

import Browser
import Css exposing (..)
import Data.Check as Check
import Dict exposing (Dict)
import Field exposing (Field)
import Field.Select as Select
import Field.Text as Text
import Html.Styled as Html exposing (Attribute, Html)
import Html.Styled.Attributes as Attrs
import Html.Styled.Events as Events
import Json.Decode as D
import Json.Encode as E
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page exposing (Page(..))
import Return2 as R2
import Style
import View.Error as Error



-- MAIN --


main : Program D.Value Model Msg
main =
    { init = init
    , view = view
    , update = update >> (<<) R2.withNoCmd
    , subscriptions = always Sub.none
    }
        |> Browser.document


init : D.Value -> ( Model, Cmd Msg )
init json =
    { page = ContactInfo
    , personalInfoFields =
        [ Text.firstName.label
        , Text.lastName.label
        , Select.gender.label
        ]
    , contactInfoFields =
        [ Text.phoneNumber.label
        , Text.email.label
        , Select.contactPreference.label
        ]
    , form =
        [ ( Text.firstName.label, Field.Text Text.firstName )
        , ( Text.lastName.label, Field.Text Text.lastName )
        , ( Text.phoneNumber.label, Field.Text Text.phoneNumber )
        , ( Text.email.label, Field.Text Text.email )
        , ( Select.gender.label, Field.Select Select.gender )
        , ( Select.contactPreference.label, Field.Select Select.contactPreference )
        ]
            |> Dict.fromList
    , formError = Nothing
    }
        |> R2.withNoCmd



-- UPDATE --


update : Msg -> Model -> Model
update msg model =
    case msg of
        FieldMsg key subMsg ->
            Model.mapField
                key
                (Field.update subMsg)
                model

        NavButtonClicked page ->
            let
                clearedModel : Model
                clearedModel =
                    Model.clearAllErrors model
            in
            case Model.validateCurrentPage clearedModel of
                Check.NoErrors ->
                    Model.setPage page clearedModel

                Check.HasErrors modelWithErrors ->
                    modelWithErrors

        SubmitClicked ->
            case Model.validate model of
                Ok submission ->
                    Model.setPage
                        (Page.Success submission)
                        model

                Err modelWithErrors ->
                    modelWithErrors



-- VIEW --


view : Model -> Browser.Document Msg
view model =
    { title = "Form Example"
    , body =
        [ Html.text "Please fill out my form!"
        , Html.div
            []
            (List.map navButton Page.formPages)
        , Html.div
            [ Attrs.css [ Style.basicMargin ] ]
            (bodyView model)
        , Error.view
            (Maybe.map Model.errorToString model.formError)
        , Html.button
            [ Events.onClick SubmitClicked ]
            [ Html.text "Submit Form" ]
        ]
            |> List.map Html.toUnstyled
    }


navButton : Page -> Html Msg
navButton page =
    Html.button
        [ Events.onClick (NavButtonClicked page) ]
        [ Html.text (Page.toString page) ]


bodyView : Model -> List (Html Msg)
bodyView model =
    case model.page of
        Success json ->
            [ Html.p
                [ Attrs.css [ color (hex "#008000") ] ]
                [ Html.text "Form was submitted! Below is the encoded json:" ]
            , Html.p
                []
                [ Html.text (E.encode 0 json) ]
            ]

        _ ->
            model
                |> Model.currentPagesFields
                |> List.map fieldView


fieldView : ( String, Field ) -> Html Msg
fieldView ( key, field ) =
    Html.map (FieldMsg key) (Field.view field)
