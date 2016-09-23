module Map2 exposing (..)

import Html exposing (Html)
import Kintail.InputWidget as InputWidget exposing (InputWidget)


main : Program Never
main =
    let
        div =
            Html.div []

        span =
            Html.span []

        label values =
            let
                description =
                    case values of
                        ( True, True ) ->
                            "Both"

                        ( True, False ) ->
                            "First only"

                        ( False, True ) ->
                            "Second only"

                        ( False, False ) ->
                            "Neither"
            in
                div [ Html.text description ]

        checkbox =
            InputWidget.checkbox []

        widget =
            InputWidget.map2 (,) fst snd span checkbox checkbox
                |> InputWidget.prepend label div
    in
        InputWidget.app widget ( True, True )
