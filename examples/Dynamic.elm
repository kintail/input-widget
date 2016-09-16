module Dynamic exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Json.Encode as Encode
import Json.Decode as Decode
import Time
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type CounterMsg
    = Click
    | Tick


counter : Int -> Bool -> InputWidget Int
counter initialCount startRunning =
    let
        init =
            ( { count = initialCount, running = startRunning }, Cmd.none )

        view { count, running } =
            Html.span []
                [ Html.text (toString count)
                , Html.button [ Html.type' "button", Html.onClick Click ]
                    [ Html.text
                        (if running then
                            "Pause"
                         else
                            "Resume"
                        )
                    ]
                ]

        update msg { count, running } =
            case msg of
                Click ->
                    ( { count = count, running = not running }, Cmd.none )

                Tick ->
                    ( { count = count + 1, running = running }, Cmd.none )

        subscriptions { count, running } =
            if running then
                Time.every (Time.second / 4) (always Tick)
            else
                Sub.none

        value { count, running } =
            count

        encodeMsg msg =
            case msg of
                Click ->
                    Encode.string "Click"

                Tick ->
                    Encode.string "Tick"

        decodeMsg =
            Decode.andThen Decode.string
                (\string ->
                    case string of
                        "Click" ->
                            Decode.succeed Click

                        "Tick" ->
                            Decode.succeed Tick

                        _ ->
                            Decode.fail "Expected 'Click' or 'Tick'"
                )
    in
        InputWidget.custom
            { init = init
            , view = view
            , update = update
            , subscriptions = subscriptions
            , value = value
            , encodeMsg = encodeMsg
            , decodeMsg = decodeMsg
            }


main : Program Never
main =
    let
        label sum =
            Html.div [] [ Html.text (toString sum) ]

        div =
            Html.div []

        widget =
            InputWidget.compose2 div
                (\firstValue secondValue -> firstValue + secondValue)
                (InputWidget.wrap div (counter 10 False))
                (InputWidget.wrap div (counter 0 True))
                |> InputWidget.append div label
    in
        InputWidget.app widget
