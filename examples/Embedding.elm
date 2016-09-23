module Embedding exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type Msg
    = NewValue Bool


type alias Model =
    { value : Bool
    , timesChanged : Int
    }


model : Model
model =
    { value = False
    , timesChanged = 0
    }


update : Msg -> Model -> Model
update (NewValue newValue) currentModel =
    { value = newValue
    , timesChanged = currentModel.timesChanged + 1
    }


checkbox : InputWidget Bool
checkbox =
    InputWidget.checkbox []


view : Model -> Html Msg
view model =
    let
        labelText =
            toString model.value
                ++ ", changed "
                ++ toString model.timesChanged
                ++ " times"
    in
        Html.div []
            [ Html.div [] [ checkbox model.value |> Html.map NewValue ]
            , Html.div [] [ Html.text labelText ]
            ]


main : Program Never
main =
    Html.beginnerProgram
        { model = model
        , update = update
        , view = view
        }
