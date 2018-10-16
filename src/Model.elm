module Model exposing
    ( Model
    , checkCurrentForm
    , clearAllErrors
    , currentForm
    , formNames
    , mapForm
    , setCurrentForm
    , submit
    , succeed
    )

import Data.Check as Check exposing (Check)
import Dict exposing (Dict)
import Field exposing (Field)
import Form exposing (Form)
import Json.Encode as E



-- TYPES --


type alias Model =
    { forms : Dict String Form
    , currentForm : String
    , success : Maybe E.Value
    }



-- HELPERS --


succeed : E.Value -> Model -> Model
succeed json model =
    { model | success = Just json }


currentForm : Model -> Maybe Form
currentForm model =
    Dict.get model.currentForm model.forms


setCurrentForm : String -> Model -> Model
setCurrentForm key model =
    { model | currentForm = key }


formNames : Model -> List String
formNames model =
    model.forms
        |> Dict.values
        |> List.sortBy .order
        |> List.map .name


mapForm : String -> (Form -> Form) -> Model -> Model
mapForm key f model =
    { model
        | forms =
            Dict.update
                key
                (Maybe.map f)
                model.forms
    }


setForm : String -> Form -> Model -> Model
setForm key form model =
    { model
        | forms =
            Dict.insert key form model.forms
    }


submit : Model -> Result Model E.Value
submit model =
    model.forms
        |> Dict.toList
        |> List.map (Tuple.mapSecond Form.submit)
        |> attemptSubmit model []


attemptSubmit :
    Model
    -> List ( String, E.Value )
    -> List ( String, Result Form (List ( String, E.Value )) )
    -> Result Model E.Value
attemptSubmit model jsonFields formResults =
    case formResults of
        ( _, Ok formsJsonFields ) :: rest ->
            attemptSubmit
                model
                (formsJsonFields ++ jsonFields)
                rest

        ( key, Err formWithErrors ) :: rest ->
            -- When we detect an error in a form
            -- we make that form the current form
            -- to view
            { model | currentForm = key }
                |> setForm key formWithErrors
                |> Err

        [] ->
            jsonFields
                |> E.object
                |> Ok


checkCurrentForm : Model -> Check Model
checkCurrentForm model =
    case Dict.get model.currentForm model.forms of
        Just form ->
            case Form.check form of
                Check.NoErrors ->
                    Check.NoErrors

                Check.HasErrors formWithErrors ->
                    { model
                        | forms =
                            Dict.insert
                                model.currentForm
                                formWithErrors
                                model.forms
                    }
                        |> Check.HasErrors

        Nothing ->
            Check.NoErrors


clearAllErrors : Model -> Model
clearAllErrors model =
    { model
        | forms =
            Dict.map
                (always Form.clearErrors)
                model.forms
    }
