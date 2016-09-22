module Kintail.InputWidget
    exposing
        ( InputWidget
        , Msg
        , Container
        , value
        , view
        , update
        , encodeMsg
        , decodeMsg
        , wrap
        , append
        , prepend
        , map
        , map2
        , checkbox
        , lineEdit
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


type Msg
    = Msg Value


type alias Container =
    List (Html Msg) -> Html Msg


value : InputWidget a -> a
value (InputWidget impl) =
    impl.value


view : (Msg -> msg) -> InputWidget a -> Html msg
view tag (InputWidget impl) =
    Html.map tag impl.html


update : Msg -> InputWidget a -> InputWidget a
update message ((InputWidget impl) as inputWidget) =
    impl.update message inputWidget


encodeMsg : Msg -> Value
encodeMsg (Msg json) =
    json


decodeMsg : Decoder Msg
decodeMsg =
    Decode.customDecoder Decode.value (\json -> Ok (Msg json))


wrap : Container -> InputWidget a -> InputWidget a
wrap container inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        value =
            impl.value

        html =
            container [ impl.html ]

        update message self =
            wrap container (impl.update message inputWidget)
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


append : (a -> Html Never) -> Container -> InputWidget a -> InputWidget a
append decoration container inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        value =
            impl.value

        html =
            container [ impl.html, Html.map never (decoration value) ]

        update message self =
            append decoration container (impl.update message inputWidget)
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


prepend : (a -> Html Never) -> Container -> InputWidget a -> InputWidget a
prepend decoration container inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        value =
            impl.value

        html =
            container [ Html.map never (decoration value), impl.html ]

        update message self =
            prepend decoration container (impl.update message inputWidget)
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            }


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


tag : Int -> Msg -> Msg
tag index (Msg json) =
    Msg (Encode.list [ Encode.int index, json ])


decodeTagged =
    Decode.decodeValue (Decode.tuple2 (,) Decode.int Decode.value)


map2 :
    (a -> b -> c)
    -> Container
    -> InputWidget a
    -> InputWidget b
    -> InputWidget c
map2 function container inputWidgetA inputWidgetB =
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

        update (Msg json) self =
            case decodeTagged json of
                Ok ( 0, jsonA ) ->
                    let
                        updatedWidgetA =
                            implA.update (Msg jsonA) inputWidgetA
                    in
                        map2 function container updatedWidgetA inputWidgetB

                Ok ( 1, jsonB ) ->
                    let
                        updatedWidgetB =
                            implB.update (Msg jsonB) inputWidgetB
                    in
                        map2 function container inputWidgetA updatedWidgetB

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
    Html.onCheck (Encode.bool >> Msg)


checkbox : List (Html.Attribute Msg) -> Bool -> InputWidget Bool
checkbox givenAttributes value =
    let
        attributes =
            checkboxType :: Html.checked value :: onCheck :: givenAttributes

        html =
            Html.input attributes []

        update (Msg json) self =
            case Decode.decodeValue Decode.bool json of
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


onInput =
    Html.onInput (Encode.string >> Msg)


lineEdit : List (Html.Attribute Msg) -> String -> InputWidget String
lineEdit givenAttributes value =
    let
        attributes =
            Html.value value :: onInput :: givenAttributes

        html =
            Html.input attributes []

        update (Msg json) self =
            case Decode.decodeValue Decode.string json of
                Ok newValue ->
                    lineEdit givenAttributes newValue

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
        toMsg =
            spec.encodeMsg >> Msg

        value =
            spec.value spec.model

        html =
            Html.map toMsg (spec.view spec.model)

        update (Msg json) self =
            case Decode.decodeValue spec.decodeMsg json of
                Ok decodedMessage ->
                    let
                        updatedModel =
                            spec.update decodedMessage spec.model
                    in
                        custom { spec | model = updatedModel }

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
    Html.beginnerProgram
        { model = inputWidget
        , view = view identity
        , update = update
        }
