module Embed exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type Msg
    = CheckboxMsg InputWidget.Msg


type alias Model =
    { checkbox : InputWidget Bool
    , timesChanged : Int
    }


init : ( Model, Cmd Msg )
init =
    let
        ( checkbox, checkboxCmd ) =
            InputWidget.init CheckboxMsg (InputWidget.checkbox [] False)
    in
        ( { checkbox = checkbox, timesChanged = 0 }, checkboxCmd )


update : Msg -> Model -> ( Model, Cmd Msg )
update message currentModel =
    case message of
        CheckboxMsg msg ->
            let
                ( updatedCheckbox, checkboxCmd ) =
                    InputWidget.update CheckboxMsg msg currentModel.checkbox

                updatedModel =
                    { checkbox = updatedCheckbox
                    , timesChanged = currentModel.timesChanged + 1
                    }
            in
                ( updatedModel, checkboxCmd )


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


subscriptions : Model -> Sub Msg
subscriptions model =
    InputWidget.subscriptions CheckboxMsg model.checkbox


main : Program Never
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
