module Kintail.InputWidget
    exposing
        ( InputWidget
        , Msg
        , Container
        , map
        , wrap
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
        , request : Cmd Msg
        , subscriptions : Sub Msg
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
            , request = impl.request
            , subscriptions = impl.subscriptions
            }


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
            , request = impl.request
            , subscriptions = impl.subscriptions
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
            , request = impl.request
            , subscriptions = impl.subscriptions
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
            , request = impl.request
            , subscriptions = impl.subscriptions
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

        request =
            Cmd.batch
                [ Cmd.map (tag 0) implA.request
                , Cmd.map (tag 1) implB.request
                ]

        subscriptions =
            Sub.batch
                [ Sub.map (tag 0) implA.subscriptions
                , Sub.map (tag 1) implB.subscriptions
                ]
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            , request = request
            , subscriptions = subscriptions
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
            , request = Cmd.none
            , subscriptions = Sub.none
            }


custom :
    { init : ( model, Cmd msg )
    , view : model -> Html msg
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , value : model -> a
    , encodeMsg : msg -> Value
    , decodeMsg : Decoder msg
    }
    -> InputWidget a
custom spec =
    let
        ( initModel, initRequest ) =
            spec.init

        value =
            spec.value initModel

        html =
            Html.map spec.encodeMsg (spec.view initModel)

        update message self =
            case Decode.decodeValue spec.decodeMsg message of
                Ok decodedMessage ->
                    let
                        newState =
                            spec.update decodedMessage initModel
                    in
                        custom { spec | init = newState }

                Err _ ->
                    self

        request =
            Cmd.map spec.encodeMsg initRequest

        subscriptions =
            Sub.map spec.encodeMsg (spec.subscriptions initModel)
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            , request = request
            , subscriptions = subscriptions
            }


app : InputWidget a -> Program Never
app inputWidget =
    let
        (InputWidget impl) =
            inputWidget

        init =
            ( inputWidget, impl.request )

        view (InputWidget impl) =
            impl.html

        update message ((InputWidget impl) as inputWidget) =
            let
                ((InputWidget newImpl) as newInputWidget) =
                    impl.update message inputWidget
            in
                ( newInputWidget, newImpl.request )

        subscriptions (InputWidget impl) =
            impl.subscriptions
    in
        Html.program
            { init = ( inputWidget, impl.request )
            , view = view
            , update = update
            , subscriptions = subscriptions
            }
