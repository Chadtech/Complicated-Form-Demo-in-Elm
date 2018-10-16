module Data.Check exposing
    ( Check(..)
    , fromResult
    , map
    )

{-| Really no different from just a Maybe,
except more expressive.

A `Check` represents a verification that
errors have been detected and and the `data`
have been updated with those errors accordingly

-}

-- TYPES --


type Check data
    = NoErrors
    | HasErrors data



-- HELPERS --


map : (a -> b) -> Check a -> Check b
map f check =
    case check of
        NoErrors ->
            NoErrors

        HasErrors data ->
            HasErrors (f data)


fromResult : Result e a -> Check e
fromResult result =
    case result of
        Err error ->
            HasErrors error

        Ok _ ->
            NoErrors
