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


update : Msg -> Model -> Model
update (NewValue newValue) currentModel =
    { value = newValue
    , timesChanged = currentModel.timesChanged + 1
    }


view : Model -> Html Msg
view { value, timesChanged } =
    let
        labelText =
            toString value ++ ", changed " ++ toString timesChanged ++ " times"
    in
        Html.div []
            [ Html.div [] [ InputWidget.checkbox [] value ]
                |> Html.map NewValue
            , Html.div [] [ Html.text labelText ]
            ]


main : Program Never
main =
    Html.beginnerProgram
        { model = { value = False, timesChanged = 0 }
        , update = update
        , view = view
        }
