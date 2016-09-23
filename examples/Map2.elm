module Map2 exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


description : ( Bool, Bool ) -> String
description values =
    case values of
        ( True, True ) ->
            "Both"

        ( True, False ) ->
            "First only"

        ( False, True ) ->
            "Second only"

        ( False, False ) ->
            "Neither"


main : Program Never
main =
    let
        checkbox =
            InputWidget.checkbox []

        checkboxPair =
            InputWidget.map2 (,) ( fst, checkbox ) ( snd, checkbox )

        widget : InputWidget ( Bool, Bool )
        widget values =
            Html.div []
                (checkboxPair values ++ [ Html.text (description values) ])
    in
        Html.beginnerProgram
            { model = ( False, True )
            , view = widget
            , update = always
            }
