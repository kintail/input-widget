module Kintail.InputWidget
    exposing
        ( InputWidget
        , Group
        , map
        , map2
        , checkbox
        , radioButton
        , lineEdit
        , custom
        )

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Html.App as Html
import Basics.Extra exposing (..)


type alias InputWidget a =
    a -> Html a


type alias Group a =
    a -> List (Html a)


map : (a -> b) -> (b -> a) -> InputWidget a -> InputWidget b
map to from inputWidget value =
    Html.map to (inputWidget (from value))


map2 :
    (a -> b -> c)
    -> ( c -> a, InputWidget a )
    -> ( c -> b, InputWidget b )
    -> Group c
map2 composeC ( extractA, inputWidgetA ) ( extractB, inputWidgetB ) valueC =
    let
        valueA =
            extractA valueC

        valueB =
            extractB valueC
    in
        [ Html.map (\newA -> composeC newA valueB) (inputWidgetA valueA)
        , Html.map (\newB -> composeC valueA newB) (inputWidgetB valueB)
        ]


checkbox : List (Html.Attribute Bool) -> InputWidget Bool
checkbox attributes value =
    Html.input
        (Html.type' "checkbox"
            :: Html.checked value
            :: Html.onCheck identity
            :: attributes
        )
        []


radioButton : List (Html.Attribute a) -> a -> InputWidget a
radioButton attributes value currentValue =
    Html.input
        (Html.type' "radio"
            :: Html.checked (value == currentValue)
            :: Html.onCheck (always value)
            :: attributes
        )
        []


lineEdit : List (Html.Attribute String) -> InputWidget String
lineEdit attributes value =
    Html.input (Html.value value :: Html.onInput identity :: attributes) []


custom : (a -> Html msg) -> (msg -> a -> a) -> InputWidget a
custom view update value =
    view value |> Html.map (\message -> update message value)
