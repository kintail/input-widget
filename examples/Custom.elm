module Custom exposing (..)

import Html exposing (Html)
import Html.Events as Html
import Json.Encode as Encode
import Json.Decode as Decode
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type CounterMsg
    = Click


button : Html CounterMsg
button =
    Html.button [ Html.onClick Click ] [ Html.text "+" ]


counter : Int -> InputWidget Int
counter initialCount =
    let
        view count =
            Html.span [] [ Html.text (toString count), button ]
    in
        InputWidget.custom
            { model = initialCount
            , view = view
            , update = \Click count -> count + 1
            , value = identity
            , encodeMsg = always Encode.null
            , decodeMsg = Decode.succeed Click
            }


main : Program Never
main =
    let
        div =
            Html.div []

        firstCounter =
            InputWidget.wrap div (counter 10)

        secondCounter =
            InputWidget.wrap div (counter 0)

        label sum =
            Html.text (toString sum)

        widget =
            InputWidget.map2 (+) div firstCounter secondCounter
                |> InputWidget.append label div
    in
        InputWidget.app widget
