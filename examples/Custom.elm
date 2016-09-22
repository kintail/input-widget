module Custom exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Json.Encode as Encode
import Json.Decode as Decode
import Time
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type CounterMsg
    = Click


counter : Int -> InputWidget Int
counter initialCount =
    let
        model =
            initialCount

        view count =
            Html.span []
                [ Html.text (toString count)
                , Html.button [ Html.type' "button", Html.onClick Click ]
                    [ Html.text "+" ]
                ]

        update msg count =
            count + 1

        value =
            identity

        encodeMsg =
            always Encode.null

        decodeMsg =
            Decode.succeed Click
    in
        InputWidget.custom
            { model = model
            , view = view
            , update = update
            , value = value
            , encodeMsg = encodeMsg
            , decodeMsg = decodeMsg
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
