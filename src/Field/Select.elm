module Field.Select exposing
    ( Error
    , Model
    , Msg
    , clearError
    , decoder
    , isEmpty
    , name
    , order
    , submit
    , update
    , view
    )

import Css exposing (..)
import Data.Submission as Submission exposing (Submission)
import Html.Styled as Html
    exposing
        ( Attribute
        , Html
        , div
        , option
        , select
        )
import Html.Styled.Attributes as Attrs
import Html.Styled.Events as Events
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as E
import Style
import Util exposing (requiredMark)
import View.Error as Error



-- TYPES --


type alias Model =
    { value : Maybe String
    , name : String
    , options : List String
    , label : String
    , error : Maybe Error
    , required : Bool
    , order : Int
    }


order : Model -> Int
order =
    .order


name : Model -> String
name =
    .name


type Msg
    = OptionSelected String


type Error
    = MustSelectOne


errorToString : Error -> String
errorToString error =
    case error of
        MustSelectOne ->
            "This field is required"



-- VALIDATION --


check : Model -> Model
check model =
    case model.value of
        Just value ->
            model

        Nothing ->
            if model.required then
                { model | error = Just MustSelectOne }

            else
                model


isEmpty : Model -> Bool
isEmpty { value } =
    value == Nothing


clearError : Model -> Model
clearError model =
    { model | error = Nothing }



-- SUBMIT --


submit : Model -> Submission Model
submit =
    submitAfterCheck << check


submitAfterCheck : Model -> Submission Model
submitAfterCheck model =
    case ( model.value, model.error ) of
        ( _, Just error ) ->
            Submission.Failed model

        ( Just value, Nothing ) ->
            ( model.name
            , E.string value
            )
                |> Submission.Encoded

        ( Nothing, Nothing ) ->
            Submission.None



-- UPDATE --


update : Msg -> Model -> Model
update msg model =
    case msg of
        OptionSelected value ->
            let
                clearedModel : Model
                clearedModel =
                    clearError model
            in
            if List.member value model.options then
                { clearedModel | value = Just value }

            else
                { clearedModel | value = Nothing }



-- VIEW --


view : Model -> Html Msg
view model =
    div
        [ Attrs.css [ Style.basicMargin ] ]
        [ Html.text
            (model.label ++ requiredMark model.required)
        , select
            [ Attrs.css [ Style.basicMargin ]
            , Events.onInput OptionSelected
            ]
            (viewOptions model)
        , Error.view
            (Maybe.map errorToString model.error)
        ]


viewOptions : Model -> List (Html Msg)
viewOptions model =
    List.map
        (optionView model.value)
        ("none selected" :: model.options)


optionView : Maybe String -> String -> Html Msg
optionView currentValue str =
    option
        [ Attrs.value str
        , Attrs.selected (Just str == currentValue)
        ]
        [ Html.text str ]



-- DECODER  --


decoder : Decoder Model
decoder =
    D.succeed Model
        |> JDP.hardcoded Nothing
        |> JDP.required "name" D.string
        |> JDP.required "options" (D.list D.string)
        |> JDP.required "name" labelDecoder
        |> JDP.hardcoded Nothing
        |> JDP.required "required" D.bool
        |> JDP.hardcoded 30


labelDecoder : Decoder String
labelDecoder =
    D.string
        |> D.map labelFromName


labelFromName : String -> String
labelFromName name_ =
    case name_ of
        "gender" ->
            "Gender"

        "preferred-means-of-contact" ->
            "Preferred Means of Contact"

        _ ->
            name_
