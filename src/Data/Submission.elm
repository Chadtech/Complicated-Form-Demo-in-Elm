module Data.Submission exposing
    ( Submission(..)
    , mapField
    )

{-| When the form needs to be submitted,
there are three possible results for each
field in the submission

0 Its valid and encodeable, and will
be included in the submission

1 Its untouched and optional, and should
just be skipped over

2 Its required and invalid and the entire
submission process should be aborted

-}

import Json.Encode as E



-- TYPES --


type Submission field
    = Encoded ( String, E.Value )
    | None
    | Failed field



-- HELPERS --


mapField : (a -> b) -> Submission a -> Submission b
mapField f submission =
    case submission of
        Encoded field ->
            Encoded field

        None ->
            None

        Failed field ->
            Failed (f field)
