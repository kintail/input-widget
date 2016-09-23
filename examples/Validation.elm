module Validation exposing (..)

import Html
import Html.Attributes as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type alias Person =
    { first : String
    , last : String
    }


personWidget : InputWidget Person
personWidget =
    let
        div =
            Html.div []

        firstNameWidget =
            InputWidget.lineEdit [ Html.placeholder "First name" ]
                |> InputWidget.wrap div

        lastNameWidget =
            InputWidget.lineEdit [ Html.placeholder "Last name" ]
                |> InputWidget.wrap div

        message person =
            case ( person.first, person.last ) of
                ( "", "" ) ->
                    "First and last names are empty"

                ( "", last ) ->
                    "First name is empty"

                ( first, "" ) ->
                    "Last name is empty"

                ( first, last ) ->
                    "Hello " ++ first ++ " " ++ last ++ "!"
    in
        InputWidget.map2 Person .first .last div firstNameWidget lastNameWidget
            |> InputWidget.append (message >> Html.text) div


main : Program Never
main =
    InputWidget.app personWidget { first = "", last = "" }
