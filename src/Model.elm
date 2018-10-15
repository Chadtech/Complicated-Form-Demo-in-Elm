module Model exposing
    ( Model
    , clearAllErrors
    , currentPagesFields
    , errorToString
    , errorsPage
    , mapField
    , setPage
    , validate
    , validateCurrentPage
    )

import Bool.Extra
import Data.Check as Check exposing (Check)
import Data.Submission as Submission exposing (Submission)
import Dict exposing (Dict)
import Field exposing (Field)
import Field.Text as Text
import Json.Encode as E
import Maybe.Extra
import Page exposing (Page(..))



-- TYPES --


type alias Model =
    { page : Page
    , personalInfoFields : List String
    , contactInfoFields : List String
    , form : Dict String Field
    , formError : Maybe Error
    }


type Error
    = NoMeansOfContact


{-| Some form-level errors need to be resolved
on certain pages. We therefore need to know
which page the error belongs to in order to
navigate to it. This function answers that
question
-}
errorsPage : Error -> Page
errorsPage error =
    case error of
        NoMeansOfContact ->
            ContactInfo


errorToString : Error -> String
errorToString error =
    case error of
        NoMeansOfContact ->
            "You must provide at least one means of contact"



-- HELPERS --


setPage : Page -> Model -> Model
setPage page model =
    { model | page = page }


currentPagesFields : Model -> List ( String, Field )
currentPagesFields model =
    pagesFields model.page model


pagesFields : Page -> Model -> List ( String, Field )
pagesFields page model =
    pagesFieldKeys page model
        |> List.map (field model.form)
        |> Maybe.Extra.values


pagesFieldKeys : Page -> Model -> List String
pagesFieldKeys page model =
    case page of
        PersonalInfo ->
            model.personalInfoFields

        ContactInfo ->
            model.contactInfoFields

        Success _ ->
            []


field : Dict String Field -> String -> Maybe ( String, Field )
field form key =
    form
        |> Dict.get key
        |> Maybe.map (Tuple.pair key)


validate : Model -> Result Model E.Value
validate model =
    case validateCurrentPage model of
        Check.NoErrors ->
            validateEveryField
                { model = model
                , fields = Dict.toList model.form
                , jsonFields = []
                }

        Check.HasErrors validatedModel ->
            Err validatedModel


type alias FieldValidationPayload =
    { model : Model
    , fields : List ( String, Field )
    , jsonFields : List ( String, E.Value )
    }


validateEveryField : FieldValidationPayload -> Result Model E.Value
validateEveryField { model, fields, jsonFields } =
    case fields of
        ( key, firstField ) :: rest ->
            case Field.submit firstField of
                Submission.Encoded jsonField ->
                    validateEveryField
                        { model = model
                        , fields = rest
                        , jsonFields = jsonField :: jsonFields
                        }

                Submission.None ->
                    validateEveryField
                        { model = model
                        , fields = rest
                        , jsonFields = jsonFields
                        }

                Submission.Failed validatedField ->
                    { model
                        | form = Dict.insert key validatedField model.form
                        , page =
                            if List.member key model.personalInfoFields then
                                PersonalInfo

                            else if List.member key model.contactInfoFields then
                                ContactInfo

                            else
                                model.page
                    }
                        |> Err

        [] ->
            jsonFields
                |> E.object
                |> Ok


validateCurrentPage : Model -> Check Model
validateCurrentPage model =
    Check.or
        (pageLevelErrors model)
        (formLevelErrors model)


pageLevelErrors : Model -> Check Model
pageLevelErrors model =
    model
        |> pagesFields model.page
        |> List.map (Tuple.mapSecond Field.throwError)
        |> List.filter (not << Field.isValid << Tuple.second)
        |> pageValidationFromInvalidFields model


pageValidationFromInvalidFields : Model -> List ( String, Field ) -> Check Model
pageValidationFromInvalidFields model invalidFields =
    if List.isEmpty invalidFields then
        Check.NoErrors

    else
        Check.HasErrors (setFields invalidFields model)


formLevelErrors : Model -> Check Model
formLevelErrors model =
    if atLeastOneMeansOfCommunication model then
        Check.NoErrors

    else
        { model | formError = Just NoMeansOfContact }
            |> Check.HasErrors


atLeastOneMeansOfCommunication : Model -> Bool
atLeastOneMeansOfCommunication model =
    [ Text.phoneNumber.label
    , Text.email.label
    ]
        |> List.map (meansOfCommunicationIsFilled model)
        |> Bool.Extra.any


meansOfCommunicationIsFilled : Model -> String -> Bool
meansOfCommunicationIsFilled model key =
    case field model.form key of
        Just ( _, field_ ) ->
            field_
                |> Field.isEmpty
                |> not

        Nothing ->
            False


clearAllErrors : Model -> Model
clearAllErrors model =
    { model
        | form = Dict.map clearFieldsErrors model.form
        , formError = Nothing
    }


clearFieldsErrors : String -> Field -> Field
clearFieldsErrors key field_ =
    Field.clearError field_


setFields : List ( String, Field ) -> Model -> Model
setFields keyValues model =
    { model | form = setFieldsInForm keyValues model.form }


setFieldsInForm : List ( String, Field ) -> Dict String Field -> Dict String Field
setFieldsInForm keyValues form =
    case keyValues of
        ( key, value ) :: rest ->
            setFieldsInForm rest (Dict.insert key value form)

        [] ->
            form


mapField : String -> (Field -> Field) -> Model -> Model
mapField key f model =
    { model
        | form =
            mapFieldDict key f model.form
    }


mapFieldDict : String -> (Field -> Field) -> Dict String Field -> Dict String Field
mapFieldDict key f =
    Dict.update key (Maybe.andThen (f >> Just))
