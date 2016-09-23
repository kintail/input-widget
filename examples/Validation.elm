module Validation exposing (..)

import Html
import Html.Attributes as Html
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type alias Person =
    { firstName : String
    , lastName : String
    }


inputWidget : InputWidget Person
inputWidget =
    let
        firstNameWidget value =
            Html.div []
                [ InputWidget.lineEdit [ Html.placeholder "First name" ] value ]

        lastNameWidget value =
            Html.div []
                [ InputWidget.lineEdit [ Html.placeholder "Last name" ] value ]
    in
        \person ->
            Html.div []
                (InputWidget.map2 Person
                    ( .firstName, firstNameWidget )
                    ( .lastName, lastNameWidget )
                    person
                )


message : Person -> String
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


main : Program Never
main =
    Html.beginnerProgram
        { model = Person "" ""
        , view =
            \person ->
                Html.div [] [ inputWidget person, Html.text (message person) ]
        , update = always
        }
