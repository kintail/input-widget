module Validation exposing (..)

import Html
import Html.Attributes as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type alias Person =
    { first : String
    , last : String
    }


makePerson : String -> String -> Result String Person
makePerson first last =
    case ( first, last ) of
        ( "", "" ) ->
            Err "First and last names are empty"

        ( "", _ ) ->
            Err "First name is empty"

        ( _, "" ) ->
            Err "Last name is empty"

        _ ->
            Ok { first = first, last = last }


personWidget : InputWidget (Result String Person)
personWidget =
    let
        div =
            Html.div []

        firstNameWidget =
            InputWidget.lineEdit [ Html.placeholder "First name" ] ""
                |> InputWidget.wrap div

        lastNameWidget =
            InputWidget.lineEdit [ Html.placeholder "Last name" ] ""
                |> InputWidget.wrap div

        resultHtml personResult =
            case personResult of
                Err errorMessge ->
                    div [ Html.text errorMessge ]

                Ok { first, last } ->
                    div [ Html.text ("Hello " ++ first ++ " " ++ last ++ "!") ]
    in
        InputWidget.map2 makePerson div firstNameWidget lastNameWidget
            |> InputWidget.append resultHtml div


main : Program Never
main =
    InputWidget.app personWidget
