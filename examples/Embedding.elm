module Embedding exposing (..)

import Html exposing (Html)
import Kintail.InputWidget as InputWidget


type Msg
    = NewValue Bool


type alias Model =
    { value : Bool
    , timesChanged : Int
    }


update : Msg -> Model -> Model
update (NewValue newValue) currentModel =
    { value = newValue
    , timesChanged = currentModel.timesChanged + 1
    }


view : Model -> Html Msg
view model =
    let
        checkbox =
            InputWidget.checkbox [] model.value |> Html.map NewValue

        label =
            Html.text
                (toString model.value
                    ++ ", changed "
                    ++ toString model.timesChanged
                    ++ " times"
                )
    in
        Html.div [] [ checkbox, label ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = { value = False, timesChanged = 0 }
        , update = update
        , view = view
        }
