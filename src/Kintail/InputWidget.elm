module Kintail.InputWidget
    exposing
        ( InputWidget
        , Container
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


type alias InputWidget a =
    a -> Html a


type alias Container a =
    List (Html a) -> Html a


wrap : Container a -> InputWidget a -> InputWidget a
wrap container inputWidget value =
    container [ inputWidget value ]


append : (a -> Html Never) -> Container a -> InputWidget a -> InputWidget a
append decoration container inputWidget value =
    container [ inputWidget value, Html.map never (decoration value) ]


prepend : (a -> Html Never) -> Container a -> InputWidget a -> InputWidget a
prepend decoration container inputWidget value =
    container [ Html.map never (decoration value), inputWidget value ]


map : (a -> b) -> (b -> a) -> InputWidget a -> InputWidget b
map to from inputWidget value =
    Html.map to (inputWidget (from value))


map2 :
    (a -> b -> c)
    -> (c -> a)
    -> (c -> b)
    -> Container c
    -> InputWidget a
    -> InputWidget b
    -> InputWidget c
map2 composeC extractA extractB container inputWidgetA inputWidgetB valueC =
    let
        valueA =
            extractA valueC

        valueB =
            extractB valueC
    in
        container
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


lineEdit : List (Html.Attribute String) -> InputWidget String
lineEdit attributes value =
    Html.input (Html.value value :: Html.onInput identity :: attributes) []


custom :
    { view : a -> Html msg
    , update : msg -> a -> a
    }
    -> InputWidget a
custom { view, update } value =
    Html.map (\message -> update message value) (view value)


app : InputWidget a -> a -> Program Never
app inputWidget initialValue =
    Html.beginnerProgram
        { model = initialValue
        , view = inputWidget
        , update = always
        }
