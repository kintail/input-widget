module Embedding exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type Msg
    = CheckboxMsg InputWidget.Msg


type alias Model =
    { checkbox : InputWidget Bool
    , timesChanged : Int
    }


model : Model
model =
    { checkbox = InputWidget.checkbox [] False, timesChanged = 0 }


update : Msg -> Model -> Model
update message currentModel =
    case message of
        CheckboxMsg msg ->
            { checkbox = InputWidget.update msg currentModel.checkbox
            , timesChanged = currentModel.timesChanged + 1
            }


view : Model -> Html Msg
view model =
    let
        label =
            toString (InputWidget.value model.checkbox)
                ++ ", changed "
                ++ toString model.timesChanged
                ++ " times"
    in
        Html.div []
            [ Html.div [] [ InputWidget.view CheckboxMsg model.checkbox ]
            , Html.div [] [ Html.text label ]
            ]


main : Program Never
main =
    Html.beginnerProgram
        { model = model
        , update = update
        , view = view
        }
