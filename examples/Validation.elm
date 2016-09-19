module Validation exposing (..)

import Html
import Html.Attributes as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


type alias Person =
    { first : String
    , last : String
    }


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

        toPerson : String -> String -> Result String Person
        toPerson first last =
            case ( first, last ) of
                ( "", "" ) ->
                    Err "First and last names are empty"

                ( "", _ ) ->
                    Err "First name is empty"

                ( _, "" ) ->
                    Err "Last name is empty"

                _ ->
                    Ok { first = first, last = last }

        resultHtml person =
            let
                resultString =
                    case person of
                        Err errorMessge ->
                            errorMessge

                        Ok { first, last } ->
                            "Hello " ++ first ++ " " ++ last ++ "!"
            in
                Html.div [] [ Html.text resultString ]
    in
        InputWidget.compose2 toPerson
            div
            firstNameWidget
            lastNameWidget
            |> InputWidget.append resultHtml div


main : Program Never
main =
    InputWidget.app personWidget
