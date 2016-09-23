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
        InputWidget.custom
            { view = view
            , update = update
            }



-- TEA


type alias Model =
    { firstValue : Int
    , secondValue : Int
    }


type Msg
    = NewFirst Int
    | NewSecond Int


view : Model -> Html Msg
view { firstValue, secondValue } =
    Html.div []
        [ Html.div [] [ counter firstValue |> Html.map NewFirst ]
        , Html.div [] [ counter secondValue |> Html.map NewSecond ]
        , Html.text (toString (firstValue + secondValue))
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        NewFirst value ->
            { model | firstValue = value }

        NewSecond value ->
            { model | secondValue = value }


main : Program Never
main =
    Html.beginnerProgram
        { model = { firstValue = 10, secondValue = 0 }
        , view = view
        , update = update
        }
