module Kintail.InputWidget
    exposing
        ( checkbox
        , radioButton
        , lineEdit
        , comboBox
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


checkbox : List (Html.Attribute Bool) -> Bool -> Html Bool
checkbox attributes value =
    Html.input
        (Html.type' "checkbox"
            :: Html.checked value
            :: Html.onCheck identity
            :: attributes
        )
        []


radioButton : List (Html.Attribute a) -> a -> a -> Html a
radioButton attributes value currentValue =
    Html.input
        (Html.type' "radio"
            :: Html.checked (value == currentValue)
            :: Html.onCheck (always value)
            :: attributes
        )
        []


lineEdit : List (Html.Attribute String) -> String -> Html String
lineEdit attributes value =
    Html.input (Html.value value :: Html.onInput identity :: attributes) []


comboBox : List (Html.Attribute a) -> (a -> String) -> List a -> a -> Html a
comboBox attributes toStr allItems =
    let
        itemsArray =
            Array.fromList allItems

        selectedIndexDecoder =
            Decode.at [ "target", "selectedIndex" ] Decode.int

        newSelectionDecoder currentItem =
            Decode.customDecoder selectedIndexDecoder
                (\selectedIndex ->
                    case Array.get selectedIndex itemsArray of
                        Just newItem ->
                            if newItem /= currentItem then
                                Ok newItem
                            else
                                Err "selected item did not change"

                        Nothing ->
                            Err "selected index out of range"
                )
    in
        (\currentItem ->
            let
                decoder =
                    newSelectionDecoder currentItem

                onChange =
                    Html.on "change" decoder

                onKeyUp =
                    Html.on "keyup" decoder

                toOption item =
                    Html.option [ Html.selected (item == currentItem) ]
                        [ Html.text (toStr item) ]
            in
                Html.select (onChange :: onKeyUp :: attributes)
                    (List.map toOption allItems)
        )


slider :
    List (Html.Attribute Float)
    -> { min : Float, max : Float, step : Float }
    -> Float
    -> Html Float
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


custom : { view : a -> Html msg, update : msg -> a -> a } -> a -> Html a
custom { view, update } value =
    view value |> Html.map (\message -> update message value)
