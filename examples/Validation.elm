module Validation exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type alias Person =
    { firstName : String
    , lastName : String
    }


message { firstName, lastName } =
    case ( firstName, lastName ) of
        ( "", "" ) ->
            "First and last names are empty"

        ( "", _ ) ->
            "First name is empty"

        ( _, "" ) ->
            "Last name is empty"

        _ ->
            "Hello " ++ firstName ++ " " ++ lastName ++ "!"


widget : InputWidget Person
widget =
    let
        firstNameWidget value =
            Html.div []
                [ InputWidget.lineEdit [ Html.placeholder "First name" ] value ]

        lastNameWidget value =
            Html.div []
                [ InputWidget.lineEdit [ Html.placeholder "Last name" ] value ]

        fields =
            InputWidget.map2 Person
                ( .firstName, firstNameWidget )
                ( .lastName, lastNameWidget )
    in
        \person ->
            Html.div [] (fields person ++ [ Html.text (message person) ])


main : Program Never
main =
    Html.beginnerProgram
        { model = Person "" ""
        , view = widget
        , update = always
        }
