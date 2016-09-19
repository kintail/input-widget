module Kintail.InputWidget
    exposing
        ( InputWidget
        , Msg
        , Container
        , init
        , value
        , view
        , update
        , subscriptions
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
        , request : Cmd Msg
        , subscriptions : Sub Msg
        }


type alias Msg =
    Value


type alias Container =
    List (Html Msg) -> Html Msg


init : (Msg -> msg) -> InputWidget a -> ( InputWidget a, Cmd msg )
init tag ((InputWidget impl) as inputWidget) =
    ( current inputWidget, Cmd.map tag impl.request )


value : InputWidget a -> a
value (InputWidget impl) =
    impl.value


view : (Msg -> msg) -> InputWidget a -> Html msg
view tag (InputWidget impl) =
    Html.map tag impl.html


update : (Msg -> msg) -> Msg -> InputWidget a -> ( InputWidget a, Cmd msg )
update tag message ((InputWidget impl) as inputWidget) =
    let
        newInputWidget =
            impl.update message inputWidget
    in
        init tag newInputWidget


subscriptions : (Msg -> msg) -> InputWidget a -> Sub msg
subscriptions tag (InputWidget impl) =
    Sub.map tag impl.subscriptions


current : InputWidget a -> InputWidget a
current (InputWidget impl) =
    InputWidget { impl | request = Cmd.none }


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
            , request = impl.request
            , subscriptions = impl.subscriptions
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
            , request = impl.request
            , subscriptions = impl.subscriptions
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
            , request = impl.request
            , subscriptions = impl.subscriptions
            }


tag : Int -> Msg -> Msg
tag index message =
    Encode.list [ Encode.int index, message ]


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

        update message self =
            case decodeTagged message of
                Ok ( 0, messageA ) ->
                    let
                        updatedWidgetA =
                            implA.update messageA inputWidgetA
                    in
                        map2 function
                            container
                            updatedWidgetA
                            (current inputWidgetB)

                Ok ( 1, messageB ) ->
                    let
                        updatedWidgetB =
                            implB.update messageB inputWidgetB
                    in
                        map2 function
                            container
                            (current inputWidgetA)
                            updatedWidgetB

                _ ->
                    current self

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
                    current self
    in
        InputWidget
            { value = value
            , html = html
            , update = update
            , request = Cmd.none
            , subscriptions = Sub.none
            }


onInput =
    Html.onInput Encode.string


lineEdit : List (Html.Attribute Msg) -> String -> InputWidget String
lineEdit givenAttributes value =
    let
        attributes =
            Html.value value :: onInput :: givenAttributes

        html =
            Html.input attributes []

        update message self =
            case Decode.decodeValue Decode.string message of
                Ok newValue ->
                    lineEdit givenAttributes newValue

                Err description ->
                    current self
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
                    current self

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
app initialInputWidget =
    let
        (InputWidget initialImpl) =
            initialInputWidget

        init =
            ( initialInputWidget, initialImpl.request )

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
            { init = init
            , view = view
            , update = update
            , subscriptions = subscriptions
            }
