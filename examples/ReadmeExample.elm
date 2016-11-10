module Readme exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget


type Title
    = Dr
    | Mrs
    | Ms
    | Mr


type alias Model =
    { title : Title
    , firstName : String
    , lastName : String
    }


type Msg
    = NewTitle Title
    | NewFirstName String
    | NewLastName String


update : Msg -> Model -> Model
update message model =
    case message of
        NewTitle newTitle ->
            { model | title = newTitle }

        NewFirstName newFirstName ->
            { model | firstName = newFirstName }

        NewLastName newLastName ->
            { model | lastName = newLastName }


view : Model -> Html Msg
view model =
    Html.div []
        [ InputWidget.comboBox [] toString [ Dr, Mrs, Ms, Mr ] model.title
            |> Html.map NewTitle
        , InputWidget.lineEdit [] model.firstName
            |> Html.map NewFirstName
        , InputWidget.lineEdit [] model.lastName
            |> Html.map NewLastName
        , Html.br [] []
        , Html.text
            ("Hello "
                ++ toString model.title
                ++ ". "
                ++ model.firstName
                ++ " "
                ++ model.lastName
                ++ "!"
            )
        ]


main : Program Never
main =
    Html.beginnerProgram
        { model = Model Dr "Albert" "Einstein"
        , update = update
        , view = view
        }
