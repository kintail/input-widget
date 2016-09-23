module RadioButton exposing (..)

import Html exposing (Html)
import Html.App as Html
import Html.Attributes as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type Size
    = Small
    | Medium
    | Large


fontSize size =
    case size of
        Small ->
            "1em"

        Medium ->
            "2em"

        Large ->
            "3em"


radioButton size currentSize =
    Html.div []
        [ InputWidget.radioButton [] size currentSize
        , Html.text (toString size)
        ]


view currentSize =
    Html.div []
        [ radioButton Small currentSize
        , radioButton Medium currentSize
        , radioButton Large currentSize
        , Html.div [ Html.style [ ( "font-size", fontSize currentSize ) ] ]
            [ Html.text "The quick brown fox..." ]
        ]


main : Program Never
main =
    Html.beginnerProgram
        { model = Small
        , view = view
        , update = always
        }
