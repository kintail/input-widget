module RadioButton exposing (..)

import Html exposing (Html)
import Html.Attributes as Attributes
import Kintail.InputWidget as InputWidget


type Size
    = Small
    | Medium
    | Large


{-| Convert a `Size` value to a string that can be used as the CSS `font-size`.
-}
fontSize : Size -> String
fontSize size =
    case size of
        Small ->
            "1em"

        Medium ->
            "2em"

        Large ->
            "3em"


{-| Helper function to construct a radio button with its associated label.
-}
radioButton : Size -> Size -> Html Size
radioButton size currentSize =
    Html.div []
        [ InputWidget.radioButton [] size currentSize
        , Html.text (toString size)
        ]


view : Size -> Html Size
view currentSize =
    Html.div []
        [ radioButton Small currentSize
        , radioButton Medium currentSize
        , radioButton Large currentSize
        , Html.div [ Attributes.style [ ( "font-size", fontSize currentSize ) ] ]
            [ Html.text "The quick brown fox..." ]
        ]


main : Program Never Size Size
main =
    Html.beginnerProgram
        { model = Small
        , view = view
        , update = always
        }
