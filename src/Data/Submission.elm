module Data.Submission exposing (Submission(..), mapField)

import Json.Encode as E



-- TYPES --


type Submission field
    = Encoded ( String, E.Value )
    | None
    | Failed field


mapField : (a -> b) -> Submission a -> Submission b
mapField f submission =
    case submission of
        Encoded field ->
            Encoded field

        None ->
            None

        Failed field ->
            Failed (f field)
