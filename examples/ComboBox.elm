module ComboBox exposing (..)

import Kintail.InputWidget as InputWidget exposing (InputWidget)
import Html exposing (Html)
import Html.App as Html


type Color
    = Red
    | Green
    | Blue


comboBox : InputWidget Color
comboBox =
    InputWidget.comboBox [] toString [ Red, Green, Blue ]


view : Color -> Html Color
view color =
    Html.div [] [ comboBox color, Html.text (toString color) ]


main : Program Never
main =
    Html.beginnerProgram
        { model = Green
        , update = always
        , view = view
        }
