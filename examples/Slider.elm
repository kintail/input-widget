module Slider exposing (..)

import Kintail.InputWidget as InputWidget
import Html exposing (Html)
import Html.App as Html


view : Float -> Html Float
view value =
    Html.div []
        [ InputWidget.slider [] { min = 0, max = 5, step = 0.1 } value
        , Html.text (toString value)
        ]


main : Program Never
main =
    Html.beginnerProgram
        { model = 1.5
        , update = always
        , view = view
        }
