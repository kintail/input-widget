module ComboBox exposing (..)

import Kintail.InputWidget as InputWidget
import Html exposing (Html)


type Color
    = Red
    | Green
    | Blue


view : Color -> Html Color
view currentColor =
    let
        comboBox =
            InputWidget.comboBox [] toString [ Red, Green, Blue ] currentColor
    in
        Html.div [] [ comboBox, Html.text (toString currentColor) ]


main : Program Never Color Color
main =
    Html.beginnerProgram
        { model = Green
        , update = always
        , view = view
        }
