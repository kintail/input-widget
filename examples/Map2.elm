module Combine2 exposing (..)

import Html exposing (Html)
import Kintail.InputWidget as InputWidget exposing (InputWidget)


main : Program Never
main =
    let
        combine ( firstValue, secondValue ) ( firstHtml, secondHtml ) =
            let
                description =
                    case ( firstValue, secondValue ) of
                        ( True, True ) ->
                            "Both"

                        ( True, False ) ->
                            "First only"

                        ( False, True ) ->
                            "Second only"

                        ( False, False ) ->
                            "Neither"

                html =
                    Html.span []
                        [ firstHtml, secondHtml, Html.text description ]
            in
                ( description, html )

        widget =
            InputWidget.map2 combine
                (InputWidget.checkbox [] False)
                (InputWidget.checkbox [] True)
    in
        InputWidget.app widget
