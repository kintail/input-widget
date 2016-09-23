module Custom exposing (..)

import Html exposing (Html)
import Html.App as Html
import Html.Events as Html
import Json.Encode as Encode
import Json.Decode as Decode
import Kintail.InputWidget as InputWidget exposing (InputWidget)


-- Counter widget


type CounterMsg
    = Increment
    | Decrement


counter : InputWidget Int
counter =
    let
        view count =
            Html.span []
                [ Html.button [ Html.onClick Decrement ] [ Html.text "-" ]
                , Html.text (toString count)
                , Html.button [ Html.onClick Increment ] [ Html.text "+" ]
                ]

        update msg count =
            case msg of
                Decrement ->
                    count - 1

                Increment ->
                    count + 1
    in
        InputWidget.custom view update



-- Application


type alias Model =
    { firstValue : Int
    , secondValue : Int
    }


type Msg
    = NewFirstValue Int
    | NewSecondValue Int


view : Model -> Html Msg
view { firstValue, secondValue } =
    Html.div []
        [ Html.div [] [ counter firstValue ] |> Html.map NewFirstValue
        , Html.div [] [ counter secondValue ] |> Html.map NewSecondValue
        , Html.text (toString (firstValue + secondValue))
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        NewFirstValue value ->
            { model | firstValue = value }

        NewSecondValue value ->
            { model | secondValue = value }


main : Program Never
main =
    Html.beginnerProgram
        { model = { firstValue = 10, secondValue = 0 }
        , view = view
        , update = update
        }
