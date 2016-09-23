module Map2 exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


main : Program Never
main =
    let
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
                Html.text description

        checkbox =
            InputWidget.checkbox []

        checkboxes =
            InputWidget.map2 (,) ( fst, checkbox ) ( snd, checkbox )

        widget : InputWidget ( Bool, Bool )
        widget values =
            Html.div [] (checkboxes values ++ [ label values ])
    in
        Html.beginnerProgram
            { model = ( False, True )
            , view = widget
            , update = always
            }
