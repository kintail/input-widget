module Kintail.InputWidget
    exposing
        ( checkbox
        , radioButton
        , lineEdit
        , comboBox
        , slider
        , custom
        )

{-| Functions for creating input widgets of the general form `a -> Html a`.

@docs checkbox, radioButton, lineEdit, comboBox, slider, custom
-}

import String
import Array exposing (Array)
import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Html.App as Html


{-| Create a `<input type="checkbox">` element with the given attributes and
current value, and which produces `Bool` messages with the new value whenever
the checkbox is clicked.

See the 'Embedding' example for sample usage.
-}
checkbox : List (Html.Attribute Bool) -> Bool -> Html Bool
checkbox attributes value =
    Html.input
        (Html.type' "checkbox"
            :: Html.checked value
            :: Html.onCheck identity
            :: attributes
        )
        []


{-| Create a `<input type="radio">` element with the given attributes. When the
radio button is checked, it will send a message equal to the first given value;
it will be displayed as currently checked if the two given values are equal to
each other.

To create a set of mutually-exclusive radio buttons (the usual case), call this
function multiple times, passing a different first value each time (the value to
be selected if the current radio button is clicked) but the same second value
(the currently selected value).

See the `RadioButton` example for sample usage.
-}
radioButton : List (Html.Attribute a) -> a -> a -> Html a
radioButton attributes value currentValue =
    Html.input
        (Html.type' "radio"
            :: Html.checked (value == currentValue)
            :: Html.onCheck (always value)
            :: attributes
        )
        []


{-| Create a simple `<input>` element with the given attributes and displayed
text. A message will be sent with the updated text whenever the text is edited.
For example,

    type Msg
        = NewFirstName String
        | NewLastName String

    type alias Model =
        { firstName : String
        , lastName : String
        }

    view : model -> Html Msg
    view =
        Html.div []
            [ Html.div []
                [ InputWidget.lineEdit [] model.firstName
                    |> Html.map NewFirstName
                ]
            , Html.div []
                [ InputWidget.lineEdit [] model.lastName
                    |> Html.map NewLastName
                ]
            ]
-}
lineEdit : List (Html.Attribute String) -> String -> Html String
lineEdit attributes value =
    Html.input (Html.value value :: Html.onInput identity :: attributes) []


{-| Create a `<select>` element with the given attributes. The `<select>`
element will be populated by `<option>` elements defined by the given list of
values, converted to text using the given function. The final given value is the
one that should be displayed as selected. A message will be sent with the newly
selected value whenever the selection is changed, either via keyboard or click.

Note that the currently selected value should be one of the values in the list,
and the list should not contain any duplicates. Otherwise it is possible that
either no values or more than one value will be marked as `selected` in the
resulting HTML.

See the `ComboBox` example for sample usage.
-}
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


{-| Create a `<range>` element with the given bounds, step size and current
value. A message will be sent with the updated value whenever the slider is
dragged.

See the `Slider` example for sample usage.
-}
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


{-| Create a custom input widget using a restricted form of the Elm Architecture
where the only allowed model is the current value to be displayed (but any
arbitrarily complex message type is allowed).

The `view` function should accept as input the current value to display, and
produce a fragment of HTML displaying that value that produces messages of some
arbitrary type of your choice. The `update` function should accept a message of
that type and the current value, and return an updated value. When called as

    InputWidget.custom { view = view, update = update }

this function will then return a function in the standard form `a -> Html a`
that effectively 'hides' the chosen message type.

See the `Custom` example for a usage example.
-}
custom : { view : a -> Html msg, update : msg -> a -> a } -> a -> Html a
custom { view, update } value =
    view value |> Html.map (\message -> update message value)
