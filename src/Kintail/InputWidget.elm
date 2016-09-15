module Kintail.InputWidget
    exposing
        ( InputWidget
        , Msg
        , map
        , map2
        , checkbox
        , custom
        , app
        )

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)
import Html exposing (Html)
import Html.Attributes as Html
import Html.Events as Html
import Html.App as Html


type InputWidget a
    = InputWidget
        { value : a
        , html : Html Msg
        , update : Msg -> InputWidget a -> InputWidget a
        }


type alias Msg =
    Value


map : (a -> Html Msg -> ( b, Html Msg )) -> InputWidget a -> InputWidget b
map function inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        update message self =
            map function (impl.update message inputWidget)

        ( value, html ) =
            function impl.value impl.html
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


tag : Int -> Html Msg -> Html Msg
tag index =
    Html.map (\message -> Encode.list [ Encode.int index, message ])


decodeTagged =
    Decode.decodeValue (Decode.tuple2 (,) Decode.int Decode.value)


map2 :
    (( a, b ) -> ( Html Msg, Html Msg ) -> ( c, Html Msg ))
    -> InputWidget a
    -> InputWidget b
    -> InputWidget c
map2 function inputWidgetA inputWidgetB =
    let
        (InputWidget implA) =
            inputWidgetA

        (InputWidget implB) =
            inputWidgetB

        ( value, html ) =
            function ( implA.value, implB.value )
                ( tag 0 implA.html, tag 1 implB.html )

        update message self =
            case decodeTagged message of
                Ok ( 0, messageA ) ->
                    let
                        updatedWidgetA =
                            implA.update messageA inputWidgetA
                    in
                        map2 function updatedWidgetA inputWidgetB

                Ok ( 1, messageB ) ->
                    let
                        updatedWidgetB =
                            implB.update messageB inputWidgetB
                    in
                        map2 function inputWidgetA updatedWidgetB

                _ ->
                    self
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


checkboxType =
    Html.type' "checkbox"


onCheck =
    Html.onCheck Encode.bool


checkbox : List (Html.Attribute Msg) -> Bool -> InputWidget Bool
checkbox givenAttributes value =
    let
        attributes =
            checkboxType :: Html.checked value :: onCheck :: givenAttributes

        html =
            Html.input attributes []

        update message self =
            case Decode.decodeValue Decode.bool message of
                Ok newValue ->
                    checkbox givenAttributes newValue

                Err description ->
                    self
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


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
        value =
            spec.value spec.model

        html =
            Html.map spec.encodeMsg (spec.view spec.model)

        update message self =
            case Decode.decodeValue spec.decodeMsg message of
                Ok decodedMessage ->
                    let
                        newModel =
                            spec.update decodedMessage spec.model
                    in
                        custom { spec | model = newModel }

                Err _ ->
                    self
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


app : InputWidget a -> Program Never
app inputWidget =
    let
        view (InputWidget impl) =
            impl.html

        update message ((InputWidget impl) as inputWidget) =
            impl.update message inputWidget
    in
        Html.beginnerProgram
            { model = inputWidget
            , view = view
            , update = update
            }
