module Kintail.OutputWidget
    exposing
        ( OutputWidget
        , Msg
        , view
        , update
        , custom
        , text
        )

import Json.Encode exposing (Value)
import Json.Decode exposing (Decoder)
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html


type Msg
    = Msg Value


type OutputWidget a
    = OutputWidget
        { view : a -> Html Msg
        , update : Msg -> OutputWidget a
        }
