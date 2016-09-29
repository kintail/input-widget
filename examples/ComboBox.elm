module ComboBox exposing (..)

import Kintail.InputWidget as InputWidget exposing (InputWidget)
import Html exposing (Html)
import Html.App as Html


type Color
    = Red
    | Green
    | Blue


type alias Model =
    { selection : InputWidget.Selection Color }


model =
    { selection = InputWidget.selection [ Red ] Green [ Blue ] }


type Msg
    = NewSelection (InputWidget.Selection Color)


update : Msg -> Model -> Model
update (NewSelection newSelection) model =
    { model | selection = newSelection }


view : Model -> Html Msg
view model =
    Html.div []
        [ InputWidget.comboBox [] toString model.selection
            |> Html.map NewSelection
        , Html.text (toString (InputWidget.selected model.selection))
        ]


main : Program Never
main =
    Html.beginnerProgram
        { model = model
        , update = update
        , view = view
        }
