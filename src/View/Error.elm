module View.Error exposing (view)

import Css exposing (..)
import Html.Styled as Html exposing (Html, p)
import Html.Styled.Attributes as Attrs


view : Maybe String -> Html msg
view maybeError =
    case maybeError of
        Just error ->
            p
                [ Attrs.css
                    [ color (hex "#ff0000")
                    , margin zero
                    ]
                ]
                [ Html.text error ]

        Nothing ->
            Html.text ""
