module Main exposing (main)

import Browser
import Css exposing (..)
import Data.Check as Check
import Data.Mock
import Flags exposing (Flags)
import Form
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attrs
import Html.Styled.Events as Events
import Json.Decode as D
import Json.Encode as E
import Model exposing (Model)
import Msg exposing (Msg(..))
import Return2 as R2
import Style
import View.Error as Error



-- MAIN --


main : Program D.Value (Result D.Error Model) Msg
main =
    { init = init
    , view = view
    , update =
        update
            >> Result.map
            >> (<<) R2.withNoCmd
    , subscriptions = always Sub.none
    }
        |> Browser.document


init : D.Value -> ( Result D.Error Model, Cmd Msg )
init json =
    case D.decodeValue Flags.decoder json of
        Ok { forms } ->
            { forms = forms
            , currentForm = Data.Mock.personalInfo.name
            , success = Nothing
            }
                |> Ok
                |> R2.withNoCmd

        Err err ->
            err
                |> Err
                |> R2.withNoCmd



-- UPDATE --


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormMsg key subMsg ->
            Model.mapForm
                key
                (Form.update subMsg)
                model

        NavButtonClicked step ->
            let
                clearedModel : Model
                clearedModel =
                    Model.clearAllErrors model
            in
            case Model.checkCurrentForm clearedModel of
                Check.NoErrors ->
                    Model.setCurrentForm step clearedModel

                Check.HasErrors modelWithErrors ->
                    modelWithErrors

        SubmitClicked ->
            case Model.submit model of
                Ok submission ->
                    Model.succeed submission model

                Err modelWithErrors ->
                    modelWithErrors



-- VIEW --


view : Result D.Error Model -> Browser.Document Msg
view result =
    case result of
        Ok model ->
            { title = "Form Example"
            , body =
                [ Html.text "Please fill out my form!"
                , Html.div
                    []
                    (List.map navButton (Model.formNames model))
                , Html.div
                    [ Attrs.css [ Style.basicMargin ] ]
                    (bodyView model)
                , Html.button
                    [ Events.onClick SubmitClicked ]
                    [ Html.text "Submit Form" ]
                ]
                    |> List.map Html.toUnstyled
            }

        Err error ->
            { title = "Form Example - ERROR"
            , body =
                [ Html.text
                    """
                    Oh no, there was a fatal 
                    error loading this example
                    """
                , Html.text (D.errorToString error)
                ]
                    |> List.map Html.toUnstyled
            }


navButton : String -> Html Msg
navButton page =
    Html.button
        [ Events.onClick (NavButtonClicked page) ]
        [ Html.text page ]


bodyView : Model -> List (Html Msg)
bodyView model =
    case ( model.success, Model.currentForm model ) of
        ( Just json, _ ) ->
            [ Html.p
                [ Attrs.css [ color (hex "#008000") ] ]
                [ Html.text
                    "Form was submitted! Below is the encoded json:"
                ]
            , Html.p
                []
                [ Html.text (E.encode 0 json) ]
            ]

        ( _, Just form ) ->
            form
                |> Form.view
                |> List.map
                    (Html.map (FormMsg model.currentForm))

        _ ->
            [ Error.view
                (Just "Oops, something went really wrong. Im sorry")
            ]
