module Kintail.InputWidget
    exposing
        ( InputWidget
        , Msg
        , value
        , view
        , update
        , custom
        , checkbox
        )

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html


type Msg
    = Msg Value


type InputWidget a
    = InputWidget
        { value : a
        , html : Html Msg
        , update : Msg -> InputWidget a
        }


value : InputWidget a -> a
value (InputWidget inputWidget) =
    inputWidget.value


view : InputWidget a -> Html Msg
view (InputWidget inputWidget) =
    inputWidget.html


update : Msg -> InputWidget a -> InputWidget a
update message (InputWidget inputWidget) =
    inputWidget.update message


custom :
    { model : model
    , view : model -> Html msg
    , update : msg -> model -> model
    , value : model -> a
    , encodeMsg : msg -> Value
    , decodeMsg : Decoder msg
    }
    -> InputWidget a
custom spec =
    let
        update message =
            case Decode.decodeValue spec.decodeMsg message of
                Ok decodedMessage ->
                    let
                        newModel =
                            spec.update decodedMessage spec.model
                    in
                        custom { spec | model = newModel }

                Err _ ->
                    currentWidget

        currentWidget =
            InputWidget
                { value = spec.value model
                , html = Html.map (spec.encodeMsg >> Msg) (spec.view model)
                , update = update
                }
    in
        currentWidget


checkboxType =
    Html.type' "checkbox"


onCheck =
    Html.onCheck (Encode.bool >> Msg)


checkbox : List (Html.Attribute Msg) -> Bool -> InputWidget Bool
checkbox givenAttributes value =
    let
        attributes =
            checkboxType :: Html.checked value :: onCheck :: givenAttributes

        update message =
            case Decode.decodeValue Decode.bool message of
                Ok newValue ->
                    checkbox givenAttributes newValue

                Err description ->
                    currentWidget

        currentWidget =
            InputWidget
                { value = value
                , html = Html.input attributes []
                , update = update
                }
    in
        currentWidget
