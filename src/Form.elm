module Form exposing
    ( Error(..)
    , Form
    , Msg
    , check
    , clearErrors
    , decoder
    , noMeansOfContact
    , submit
    , update
    , view
    )

import Bool.Extra
import Data.Check as Check exposing (Check)
import Data.Submission as Submission exposing (Submission)
import Dict exposing (Dict)
import Field exposing (Field)
import Html.Styled as Html exposing (Html)
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as E
import Maybe.Extra as ME
import Util exposing (toValidation)
import View.Error as Error



-- TYPES --


{-| Not the entire form, but one step
in a multi part form
-}
type alias Form =
    { label : String
    , name : String
    , fields : Dict String Field
    , error : Maybe Error
    , validations : List (Dict String Field -> Maybe Error)
    , order : Int
    }


mapField : String -> (Field -> Field) -> Form -> Form
mapField key f form =
    { form
        | fields =
            Dict.update
                key
                (Maybe.map f)
                form.fields
    }


type Error
    = NoMeansOfContact


type Msg
    = FieldMsg String Field.Msg


errorToString : Error -> String
errorToString error =
    case error of
        NoMeansOfContact ->
            "You must provide at least one means of contact"


clearErrors : Form -> Form
clearErrors form =
    { form
        | fields = Dict.map (always Field.clearError) form.fields
        , error = Nothing
    }



-- VALIDATION --


submit : Form -> Result Form (List ( String, E.Value ))
submit form =
    case checkFormLevelErrors form of
        Check.HasErrors formWithErrors ->
            Err formWithErrors

        Check.NoErrors ->
            attemptSubmit
                { form = form
                , fields = Dict.toList form.fields
                , jsonFields = []
                }


check : Form -> Check Form
check =
    Check.fromResult << submit


checkFormLevelErrors : Form -> Check Form
checkFormLevelErrors ({ fields, validations } as form) =
    case ME.values (List.map ((|>) fields) validations) of
        error :: rest ->
            Check.HasErrors { form | error = Just error }

        [] ->
            Check.NoErrors


type alias SubmitPayload =
    { form : Form
    , fields : List ( String, Field )
    , jsonFields : List ( String, E.Value )
    }


attemptSubmit : SubmitPayload -> Result Form (List ( String, E.Value ))
attemptSubmit { form, fields, jsonFields } =
    case fields of
        ( key, firstField ) :: rest ->
            case Field.submit firstField of
                Submission.Encoded jsonField ->
                    { form = form
                    , fields = rest
                    , jsonFields = jsonField :: jsonFields
                    }
                        |> attemptSubmit

                Submission.None ->
                    { form = form
                    , fields = rest
                    , jsonFields = jsonFields
                    }
                        |> attemptSubmit

                Submission.Failed validatedField ->
                    { form
                        | fields =
                            Dict.insert
                                key
                                validatedField
                                form.fields
                    }
                        |> Err

        [] ->
            jsonFields
                |> Ok


noMeansOfContact : Dict String Field -> Bool
noMeansOfContact fields =
    [ "phone-number"
    , "email"
    ]
        |> List.map (fieldIsEmpty fields)
        |> Bool.Extra.all


fieldIsEmpty : Dict String Field -> String -> Bool
fieldIsEmpty fields key =
    Dict.get key fields
        |> Maybe.map Field.isEmpty
        |> Maybe.withDefault True



-- UDPATE --


update : Msg -> Form -> Form
update msg form =
    case msg of
        FieldMsg fieldName subMsg ->
            mapField
                fieldName
                (Field.update subMsg)
                form



-- VIEW --


view : Form -> List (Html Msg)
view form =
    [ Html.text form.label
    , Html.div
        []
        (fieldsView form)
    , Error.view
        (Maybe.map errorToString form.error)
    ]


fieldsView : Form -> List (Html Msg)
fieldsView form =
    form.fields
        |> Dict.toList
        |> List.sortBy (Tuple.second >> Field.order)
        |> List.map fieldView


fieldView : ( String, Field ) -> Html Msg
fieldView ( key, field ) =
    Html.map (FieldMsg key) (Field.view field)



-- DECODER --


decoder : Decoder Form
decoder =
    D.succeed Form
        |> JDP.custom labelDecoder
        |> JDP.required "name" D.string
        |> JDP.required "fields" fieldsDecoder
        |> JDP.hardcoded Nothing
        |> JDP.custom validationsDecoder
        |> JDP.custom orderDecoder


fieldsDecoder : Decoder (Dict String Field)
fieldsDecoder =
    Field.decoder
        |> D.list
        |> D.map fieldsToDict


fieldsToDict : List Field -> Dict String Field
fieldsToDict fields =
    case fields of
        first :: rest ->
            Dict.insert
                (Field.name first)
                first
                (fieldsToDict rest)

        [] ->
            Dict.empty


labelDecoder : Decoder String
labelDecoder =
    D.string
        |> D.field "name"
        |> D.map labelFromName


labelFromName : String -> String
labelFromName name =
    case name of
        "personal-information" ->
            "Personal Information"

        "contact-information" ->
            "Contact Information"

        _ ->
            name


orderDecoder : Decoder Int
orderDecoder =
    D.string
        |> D.field "name"
        |> D.map orderFromName


orderFromName : String -> Int
orderFromName name =
    case name of
        "personal-information" ->
            0

        "contact-information" ->
            1

        _ ->
            9001


validationsDecoder : Decoder (List (Dict String Field -> Maybe Error))
validationsDecoder =
    [ D.string
        |> D.field "name"
        |> D.andThen noMeansOfContactDecoder
    ]
        |> D.oneOf


noMeansOfContactDecoder : String -> Decoder (List (Dict String Field -> Maybe Error))
noMeansOfContactDecoder str =
    case str of
        "contact-information" ->
            ( NoMeansOfContact, noMeansOfContact )
                |> toValidation
                |> List.singleton
                |> D.succeed

        _ ->
            D.succeed []
