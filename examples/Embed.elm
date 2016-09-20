module Embed exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type Msg
    = CheckboxMsg InputWidget.Msg


type alias Model =
    { checkboxState : InputWidget.State Bool
    , timesChanged : Int
    }


init : ( Model, Cmd Msg )
init =
    let
        ( checkboxState, checkboxCmd ) =
            InputWidget.init CheckboxMsg (InputWidget.checkbox [] False)
    in
        ( { checkboxState = checkboxState, timesChanged = 0 }, checkboxCmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update message currentModel =
    case message of
        CheckboxMsg msg ->
            let
                currentCheckboxState =
                    currentModel.checkboxState

                ( updatedCheckboxState, checkboxCmd ) =
                    InputWidget.update CheckboxMsg msg currentCheckboxState

                updatedModel =
                    { checkboxState = updatedCheckboxState
                    , timesChanged = currentModel.timesChanged + 1
                    }
            in
                ( updatedModel, checkboxCmd )


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
            [ Html.div [] [ InputWidget.view CheckboxMsg model.checkboxState ]
            , Html.div [] [ Html.text label ]
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    InputWidget.subscriptions CheckboxMsg model.checkboxState


main : Program Never
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
