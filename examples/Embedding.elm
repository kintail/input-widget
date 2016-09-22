module Embedding exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type Msg
    = CheckboxMsg InputWidget.Msg


type alias Model =
    { checkboxState : InputWidget.State Msg Bool
    , timesChanged : Int
    }


model : Model
model =
    let
        checkboxState =
            InputWidget.init CheckboxMsg (InputWidget.checkbox [] False)
    in
        { checkboxState = checkboxState, timesChanged = 0 }


update : Msg -> Model -> Model
update message currentModel =
    case message of
        CheckboxMsg msg ->
            let
                currentCheckboxState =
                    currentModel.checkboxState

                updatedCheckboxState =
                    InputWidget.update msg currentCheckboxState
            in
                { checkboxState = updatedCheckboxState
                , timesChanged = currentModel.timesChanged + 1
                }


view : Model -> Html Msg
view model =
    let
        label =
            toString (InputWidget.value model.checkboxState)
                ++ ", changed "
                ++ toString model.timesChanged
                ++ " times"
    in
        Html.div []
            [ Html.div [] [ InputWidget.view model.checkboxState ]
            , Html.div [] [ Html.text label ]
            ]


main : Program Never
main =
    Html.beginnerProgram
        { model = model
        , update = update
        , view = view
        }
