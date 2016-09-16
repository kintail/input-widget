module Kintail.InputWidget
    exposing
        ( InputWidget
        , Msg
        , map
        , append
        , prepend
        , compose2
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
import Basics.Extra exposing (..)


type InputWidget a
    = InputWidget
        { value : a
        , html : Html Msg
        , update : Msg -> InputWidget a -> InputWidget a
        }


type alias Msg =
    Value


type alias Container =
    List (Html Msg) -> Html Msg


map : (a -> b) -> InputWidget a -> InputWidget b
map function inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        update message self =
            map function (impl.update message inputWidget)
    in
        InputWidget
            { value = function impl.value
            , html = impl.html
            , update = update
            }


append : Container -> (a -> Html Never) -> InputWidget a -> InputWidget a
append container decoration inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        value =
            impl.value

        html =
            container [ impl.html, Html.map never (decoration value) ]

        update message self =
            append container decoration (impl.update message inputWidget)
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


prepend : Container -> (a -> Html Never) -> InputWidget a -> InputWidget a
prepend container decoration inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        value =
            impl.value

        html =
            container [ Html.map never (decoration value), impl.html ]

        update message self =
            prepend container decoration (impl.update message inputWidget)
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


tag : Int -> Msg -> Msg
tag index message =
    Encode.list [ Encode.int index, message ]


decodeTagged =
    Decode.decodeValue (Decode.tuple2 (,) Decode.int Decode.value)


compose2 :
    Container
    -> (a -> b -> c)
    -> InputWidget a
    -> InputWidget b
    -> InputWidget c
compose2 container function inputWidgetA inputWidgetB =
    let
        (InputWidget implA) =
            inputWidgetA

        (InputWidget implB) =
            inputWidgetB

        value =
            function implA.value implB.value

        html =
            container
                [ Html.map (tag 0) implA.html
                , Html.map (tag 1) implB.html
                ]

        update message self =
            case decodeTagged message of
                Ok ( 0, messageA ) ->
                    let
                        updatedWidgetA =
                            implA.update messageA inputWidgetA
                    in
                        compose2 container function updatedWidgetA inputWidgetB

                Ok ( 1, messageB ) ->
                    let
                        updatedWidgetB =
                            implB.update messageB inputWidgetB
                    in
                        compose2 container function inputWidgetA updatedWidgetB

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
