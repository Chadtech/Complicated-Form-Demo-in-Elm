module Field.Select exposing
    ( Error
    , Model
    , Msg
    , clearError
    , contactPreference
    , gender
    , isEmpty
    , submit
    , throwError
    , update
    , validate
    , view
    )

import Css exposing (..)
import Data.Submission as Submission exposing (Submission)
import Html.Styled as Html
    exposing
        ( Attribute
        , Html
        , div
        , option
        , select
        )
import Html.Styled.Attributes as Attrs
import Html.Styled.Events as Events
import Json.Decode as D
import Json.Encode as E
import Style
import View.Error as Error



-- TYPES --


type alias Model =
    { value : Maybe String
    , options : List String
    , label : String
    , error : Maybe Error
    , required : Bool
    }


type Msg
    = OptionSelected String
    | SelectBlurred


type Error
    = MustSelectOne


errorToString : Error -> String
errorToString error =
    case error of
        MustSelectOne ->
            "This field is required"



-- VALIDATION --


throwError : Model -> Model
throwError model =
    case validate model of
        Err newModel ->
            newModel

        Ok _ ->
            model


validate : Model -> Result Model String
validate model =
    case model.value of
        Just value ->
            Ok value

        Nothing ->
            if model.required then
                Err { model | error = Just MustSelectOne }

            else
                Err model


isEmpty : Model -> Bool
isEmpty { value } =
    value == Nothing


clearError : Model -> Model
clearError model =
    { model | error = Nothing }



-- SUBMIT --


submit : Model -> Submission Model
submit model =
    case validate model of
        Ok value ->
            ( model.label
            , E.string value
            )
                |> Submission.Encoded

        Err validatedModel ->
            case validatedModel.error of
                Just error ->
                    Submission.Failed validatedModel

                Nothing ->
                    Submission.None



-- UPDATE --


update : Msg -> Model -> Model
update msg model =
    case msg of
        OptionSelected value ->
            let
                clearedModel : Model
                clearedModel =
                    clearError model
            in
            if List.member value model.options then
                { clearedModel | value = Just value }

            else
                { clearedModel | value = Nothing }

        SelectBlurred ->
            throwError model



-- VIEW --


view : Model -> Html Msg
view model =
    div
        [ Attrs.css [ Style.basicMargin ] ]
        [ Html.text model.label
        , select
            [ Attrs.css [ Style.basicMargin ]
            , onChange OptionSelected
            ]
            (viewOptions model)
        , Error.view
            (Maybe.map errorToString model.error)
        ]


onChange : (String -> msg) -> Attribute msg
onChange msgCtor =
    D.string
        |> D.at [ "target", "value" ]
        |> D.map msgCtor
        |> Events.on "change"


viewOptions : Model -> List (Html Msg)
viewOptions model =
    List.map
        (optionView model.value)
        ("none selected" :: model.options)


optionView : Maybe String -> String -> Html Msg
optionView currentValue str =
    option
        [ Attrs.value str
        , Attrs.selected (Just str == currentValue)
        ]
        [ Html.text str ]



-- HARDCODED DATA --


gender : Model
gender =
    { value = Nothing
    , options = [ "male", "female" ]
    , label = "Gender*"
    , error = Nothing
    , required = True
    }


contactPreference : Model
contactPreference =
    { value = Nothing
    , options = [ "phone", "email" ]
    , label = "Preferred Means of Contact"
    , error = Nothing
    , required = False
    }
