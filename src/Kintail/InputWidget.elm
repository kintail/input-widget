module Kintail.InputWidget
    exposing
        ( InputWidget
        , Selection
        , checkbox
        , radioButton
        , lineEdit
        , comboBox
        , selection
        , selected
        , slider
        , custom
        )

import String
import Array exposing (Array)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Html.App as Html
import Basics.Extra exposing (..)


type alias InputWidget a =
    a -> Html a


type Selection a
    = Selection a (Array a)


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


comboBox :
    List (Html.Attribute (Selection a))
    -> (a -> String)
    -> InputWidget (Selection a)
comboBox attributes toStr (Selection currentItem allItems) =
    let
        selectedIndexDecoder =
            Decode.at [ "target", "selectedIndex" ] Decode.int

        newSelectionDecoder =
            Decode.customDecoder selectedIndexDecoder
                (\selectedIndex ->
                    case Array.get selectedIndex allItems of
                        Just newItem ->
                            if newItem == currentItem then
                                Err "selected item did not change"
                            else
                                Ok (Selection newItem allItems)

                        Nothing ->
                            Err "selected index out of range"
                )

        onChange =
            Html.on "change" newSelectionDecoder

        onKeyUp =
            Html.on "keyup" newSelectionDecoder

        toOption item =
            Html.option [ Html.selected (item == currentItem) ]
                [ Html.text (toStr item) ]
    in
        Html.select (onChange :: onKeyUp :: attributes)
            (List.map toOption (Array.toList allItems))


selection : List a -> a -> List a -> Selection a
selection previous selected following =
    Selection selected (Array.fromList (previous ++ [ selected ] ++ following))


selected : Selection a -> a
selected (Selection currentItem allItems) =
    currentItem


slider :
    List (Html.Attribute Float)
    -> { min : Float, max : Float, step : Float }
    -> InputWidget Float
slider attributes { min, max, step } value =
    let
        valueDecoder =
            Decode.map (String.toFloat >> Result.withDefault value)
                Html.targetValue
    in
        Html.input
            (Html.type' "range"
                :: Html.property "min" (Encode.float min)
                :: Html.property "max" (Encode.float max)
                :: Html.property "step" (Encode.float step)
                :: Html.property "value" (Encode.float value)
                :: Html.on "input" valueDecoder
                :: attributes
            )
            []


custom : (a -> Html msg) -> (msg -> a -> a) -> InputWidget a
custom view update value =
    view value |> Html.map (\message -> update message value)
