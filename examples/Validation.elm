module Validation exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.App as Html
import Kintail.InputWidget as InputWidget


type alias Person =
    { firstName : String
    , lastName : String
    }


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


widget : Person -> Html Person
widget person =
    let
        { firstName, lastName } =
            person

        firstNameWidget =
            InputWidget.lineEdit [ Html.placeholder "First name" ] firstName
                |> Html.map (\newFirstName -> Person newFirstName lastName)

        lastNameWidget =
            InputWidget.lineEdit [ Html.placeholder "Last name" ] lastName
                |> Html.map (\newLastName -> Person firstName newLastName)
    in
        Html.div []
            [ Html.div [] [ firstNameWidget ]
            , Html.div [] [ lastNameWidget ]
            , Html.text (message person)
            ]


main : Program Never
main =
    Html.beginnerProgram
        { model = Person "" ""
        , view = widget
        , update = always
        }
