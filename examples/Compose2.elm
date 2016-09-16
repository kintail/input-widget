module Combine2 exposing (..)

import Html exposing (Html)
import Kintail.InputWidget as InputWidget exposing (InputWidget)


main : Program Never
main =
    let
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
            Html.div [] [ Html.text text ]

        widget =
            InputWidget.compose2 (Html.span [])
                description
                (InputWidget.checkbox [] False)
                (InputWidget.checkbox [] True)
                |> InputWidget.prepend (Html.div []) label
    in
        InputWidget.app widget
