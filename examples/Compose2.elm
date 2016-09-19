module Combine2 exposing (..)

import Html exposing (Html)
import Kintail.InputWidget as InputWidget exposing (InputWidget)


main : Program Never
main =
    let
        div =
            Html.div []

        span =
            Html.span []

        description firstValue secondValue =
            case ( firstValue, secondValue ) of
                ( True, True ) ->
                    "Both"

                ( True, False ) ->
                    "First only"

                ( False, True ) ->
                    "Second only"

                ( False, False ) ->
                    "Neither"

        label text =
            div [ Html.text text ]

        widget =
            InputWidget.compose2 description
                span
                (InputWidget.checkbox [] False)
                (InputWidget.checkbox [] True)
                |> InputWidget.prepend label div
    in
        InputWidget.app widget
