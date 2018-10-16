module Field.Text exposing
    ( Error(..)
    , Model
    , Msg
    , containsLetters
    , decoder
    , isEmpty
    , isntValidEmail
    , name
    , order
    , submit
    , update
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
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as E
import Style
import Util exposing (requiredMark, toValidation)
import Validate
import View.Error as Error



-- TYPES --


type alias Model =
    { value : String
    , label : String
    , name : String
    , validations : List (String -> Maybe Error)
    , error : Maybe Error
    , validateOnUpdate : Bool
    , required : Bool
    , order : Int
    }


order : Model -> Int
order =
    .order


name : Model -> String
name =
    .name


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


check : Model -> Model
check model =
    checkHelper model.validations model


checkHelper : List (String -> Maybe Error) -> Model -> Model
checkHelper validations model =
    case validations of
        firstValidation :: rest ->
            case firstValidation model.value of
                Just error ->
                    { model | error = Just error }

                Nothing ->
                    checkHelper rest model

        [] ->
            { model | error = Nothing }


isEmpty : Model -> Bool
isEmpty { value } =
    String.isEmpty value


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
submit =
    submitAfterCheck << check


submitAfterCheck : Model -> Submission Model
submitAfterCheck model =
    if model.error == Nothing then
        if isEmpty model then
            Submission.None

        else
            ( model.name
            , E.string model.value
            )
                |> Submission.Encoded

    else
        Submission.Failed model



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
                check newModel

            else
                newModel

        FieldBlurred ->
            check model



-- VIEW --


view : Model -> Html Msg
view model =
    div
        [ Attrs.css [ Style.basicMargin ] ]
        [ Html.text
            (model.label ++ requiredMark model.required)
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



-- DECODER --


decoder : Decoder Model
decoder =
    D.succeed Model
        |> JDP.hardcoded ""
        |> JDP.custom labelDecoder
        |> JDP.required "name" D.string
        |> JDP.required "validations" (D.list validationDecoder)
        |> JDP.hardcoded Nothing
        |> JDP.custom validateOnUpdateDecoder
        |> JDP.required "required" D.bool
        |> JDP.custom orderDecoder


labelDecoder : Decoder String
labelDecoder =
    D.string
        |> D.field "name"
        |> D.map labelFromName


labelFromName : String -> String
labelFromName name_ =
    case name_ of
        "first-name" ->
            "First Name"

        "last-name" ->
            "Last Name"

        "gender" ->
            "Gender"

        "phone-number" ->
            "Phone Number"

        "email" ->
            "Email"

        "means-of-contact-preference" ->
            "Preferred Means of Contact"

        _ ->
            name_


validationDecoder : Decoder (String -> Maybe Error)
validationDecoder =
    D.string
        |> D.andThen validationDecoderFromString
        |> D.map toValidation


validationDecoderFromString : String -> Decoder ( Error, String -> Bool )
validationDecoderFromString validation =
    case validation of
        "is-blank" ->
            ( IsBlank, String.isEmpty )
                |> D.succeed

        "isnt-phone-number" ->
            ( IsntPhoneNumber, containsLetters )
                |> D.succeed

        "isnt-valid-email" ->
            ( IsntValidEmail, isntValidEmail )
                |> D.succeed

        _ ->
            D.fail "Unknown Validation"


validateOnUpdateDecoder : Decoder Bool
validateOnUpdateDecoder =
    D.string
        |> D.field "name"
        |> D.map validateOnUpdateFromName


validateOnUpdateFromName : String -> Bool
validateOnUpdateFromName name_ =
    case name_ of
        "phone-number" ->
            True

        _ ->
            False


orderDecoder : Decoder Int
orderDecoder =
    D.string
        |> D.field "name"
        |> D.map orderFromName


orderFromName : String -> Int
orderFromName name_ =
    case name_ of
        "first-name" ->
            0

        "last-name" ->
            10

        "gender" ->
            30

        "phone-number" ->
            0

        "email" ->
            10

        "means-of-contact-preference" ->
            30

        _ ->
            9001
