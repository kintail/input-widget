module ComboBox exposing (..)

import Kintail.InputWidget as InputWidget exposing (InputWidget)
import Html exposing (Html)
import Html.App as Html


type Color
    = Red
    | Green
    | Blue


view : InputWidget.Selection Color -> Html (InputWidget.Selection Color)
view selection =
    Html.div []
        [ InputWidget.comboBox [] toString selection
        , Html.text (toString (InputWidget.selected selection))
        ]


main : Program Never
main =
    Html.beginnerProgram
        { model = InputWidget.selection [ Red ] Green [ Blue ]
        , update = always
        , view = view
        }
