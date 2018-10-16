module Util exposing
    ( requiredMark
    , toValidation
    )


toValidation : ( error, value -> Bool ) -> value -> Maybe error
toValidation ( error, condition ) str =
    if condition str then
        Just error

    else
        Nothing


requiredMark : Bool -> String
requiredMark required =
    if required then
        "*"

    else
        ""
