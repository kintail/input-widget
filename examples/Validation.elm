module Validation exposing (..)

import Html exposing (Html)
import Html.Attributes as Html
import Html.App as Html
import Kintail.InputWidget as InputWidget


type alias Person =
    { firstName : String
    , lastName : String
    }


{-| Generate a simple validation message for given first and last names.
-}
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


{-| Create a high-level input widget that displays values of type `Person` and
produces messages with updated (edited) `Person` values.
-}
widget : Person -> Html Person
widget person =
    let
        { firstName, lastName } =
            person

        -- Note how `Html.map` is used: when a new first name is entered, it is
        -- combined with the existing last name to form a new `Person` value
        -- that can then be produced as a message (and vice versa in
        -- `lastNameWidget` below)
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
