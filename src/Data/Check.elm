module Data.Check exposing (Check(..), or)


type Check d
    = NoErrors
    | HasErrors d


or : Check d -> Check d -> Check d
or c0 c1 =
    case ( c0, c1 ) of
        ( HasErrors e0, _ ) ->
            HasErrors e0

        ( _, HasErrors e1 ) ->
            HasErrors e1

        _ ->
            NoErrors
