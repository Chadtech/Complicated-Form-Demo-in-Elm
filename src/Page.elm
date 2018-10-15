module Page exposing
    ( Page(..)
    , formPages
    , toString
    )

import Json.Encode as E



-- TYPES --


type Page
    = PersonalInfo
    | ContactInfo
    | Success E.Value


formPages : List Page
formPages =
    [ PersonalInfo
    , ContactInfo
    ]



-- HELPERS --


toString : Page -> String
toString page =
    case page of
        PersonalInfo ->
            "Personal"

        ContactInfo ->
            "Contact"

        Success _ ->
            "Success"
