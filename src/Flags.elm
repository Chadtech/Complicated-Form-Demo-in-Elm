module Flags exposing
    ( Flags
    , decoder
    )

import Dict exposing (Dict)
import Form exposing (Form)
import Json.Decode as D exposing (Decoder)



-- TYPES --


type alias Flags =
    { forms : Dict String Form }



-- DECODER --


decoder : Decoder Flags
decoder =
    Form.decoder
        |> D.list
        |> D.map (Flags << formsToDict)
        |> D.field "forms"


formsDecoder : Decoder (Dict String Form)
formsDecoder =
    Form.decoder
        |> D.list
        |> D.map formsToDict


formsToDict : List Form -> Dict String Form
formsToDict forms =
    case forms of
        first :: rest ->
            Dict.insert
                first.name
                first
                (formsToDict rest)

        [] ->
            Dict.empty
