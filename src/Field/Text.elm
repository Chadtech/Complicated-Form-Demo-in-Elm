module Field.Text exposing
    ( Error(..)
    , Model
    , Msg
    , email
    , firstName
    , isEmpty
    , lastName
    , phoneNumber
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
        ( Html
        , div
        , input
        , p
        )
import Html.Styled.Attributes as Attrs
import Html.Styled.Events as Events
import Json.Encode as E
import Style
import Validate
import View.Error as Error



-- TYPES --


type alias Model =
    { value : String
    , label : String
    , validations : List (String -> Maybe Error)
    , error : Maybe Error
    , validateOnUpdate : Bool
    , required : Bool
    }


type Msg
    = TextUpdated String
    | FieldBlurred


type Error
    = IsBlank
    | IsntPhoneNumber
    | IsntValidEmail


errorToString : Error -> String
errorToString error =
    case error of
        IsBlank ->
            "Field cannot be empty"

        IsntPhoneNumber ->
            "Field isnt a valid phone number"

        IsntValidEmail ->
            "Field must be a valid email"



-- VALIDATION --


throwError : Model -> Model
throwError model =
    throwErrorHelper model.validations model


throwErrorHelper : List (String -> Maybe Error) -> Model -> Model
throwErrorHelper validations model =
    case validations of
        firstValidation :: rest ->
            case firstValidation model.value of
                Just error ->
                    { model | error = Just error }

                Nothing ->
                    throwErrorHelper rest model

        [] ->
            { model | error = Nothing }


validate : Model -> Result Model String
validate model =
    let
        checkedModel : Model
        checkedModel =
            throwError model
    in
    if model.error == Nothing then
        Ok model.value

    else
        Err checkedModel


isEmpty : Model -> Bool
isEmpty { value } =
    String.isEmpty value


toValidation : ( Error, String -> Bool ) -> String -> Maybe Error
toValidation ( error, condition ) str =
    if condition str then
        Just error

    else
        Nothing


containsLetters : String -> Bool
containsLetters str =
    "abcdefghijklmnopqrstuvwxyz"
        |> String.toList
        |> List.map String.fromChar
        |> containsLettersHelper (String.toLower str)


containsLettersHelper : String -> List String -> Bool
containsLettersHelper str alphabet =
    case alphabet of
        first :: rest ->
            if String.contains first str then
                True

            else
                containsLettersHelper str rest

        [] ->
            False


isntValidEmail : String -> Bool
isntValidEmail emailStr =
    (not <| String.isEmpty emailStr) && (not <| Validate.isValidEmail emailStr)



-- SUBMIT --


submit : Model -> Submission Model
submit model =
    case validate model of
        Err validatedModel ->
            if model.required then
                Submission.Failed validatedModel

            else
                Submission.None

        Ok "" ->
            Submission.None

        Ok value ->
            ( model.label
            , E.string value
            )
                |> Submission.Encoded



-- UPDATE --


update : Msg -> Model -> Model
update msg model =
    case msg of
        TextUpdated newText ->
            let
                newModel : Model
                newModel =
                    { model | value = newText }
            in
            if model.validateOnUpdate then
                throwError newModel

            else
                newModel

        FieldBlurred ->
            throwError model



-- VIEW --


view : Model -> Html Msg
view model =
    div
        [ Attrs.css [ Style.basicMargin ] ]
        [ Html.text model.label
        , input
            [ Attrs.css [ Style.basicMargin ]
            , Attrs.value model.value
            , Events.onInput TextUpdated
            , Events.onBlur FieldBlurred
            ]
            []
        , Error.view
            (Maybe.map errorToString model.error)
        ]



-- HARDCODED DATA --


firstName : Model
firstName =
    { value = ""
    , label = "First Name"
    , validations = []
    , error = Nothing
    , validateOnUpdate = False
    , required = False
    }


lastName : Model
lastName =
    { value = ""
    , label = "Last Name*"
    , validations =
        [ ( IsBlank, String.isEmpty ) ]
            |> List.map toValidation
    , error = Nothing
    , validateOnUpdate = False
    , required = True
    }


phoneNumber : Model
phoneNumber =
    { value = ""
    , label = "Phone Number"
    , validations =
        [ ( IsntPhoneNumber, containsLetters ) ]
            |> List.map toValidation
    , error = Nothing
    , validateOnUpdate = True
    , required = False
    }


email : Model
email =
    { value = ""
    , label = "Email"
    , validations =
        [ ( IsntValidEmail, isntValidEmail ) ]
            |> List.map toValidation
    , error = Nothing
    , validateOnUpdate = False
    , required = False
    }
