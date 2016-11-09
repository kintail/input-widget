module Custom exposing (..)

import Html exposing (Html)
import Html.App as Html
import Html.Events as Html
import Kintail.InputWidget as InputWidget


-- Counter widget


type CounterMsg
    = Increment
    | Decrement


{-| Create a custom counter widget that displays a count along with buttons to
increment or decrement it. Note that although `Increment` and `Decrement`
messages are used internally by `update` and `view`, from the outside the only
message produced by the widget is simply 'new value' of type `Int`.
-}
counter : Int -> Html Int
counter =
    let
        -- Standard Elm Architecture view function
        view : Int -> Html CounterMsg
        view count =
            Html.span []
                [ Html.button [ Html.onClick Decrement ] [ Html.text "-" ]
                , Html.text (toString count)
                , Html.button [ Html.onClick Increment ] [ Html.text "+" ]
                ]

        -- Standard Elm Architecture update function
        update : CounterMsg -> Int -> Int
        update msg count =
            case msg of
                Decrement ->
                    count - 1

                Increment ->
                    count + 1
    in
        InputWidget.custom { view = view, update = update }



-- Sample application: two independent counters


type alias Model =
    { firstValue : Int
    , secondValue : Int
    }


type Msg
    = NewFirstValue Int
    | NewSecondValue Int


{-| Render the two counters, tagging the updated values produced by each one
with a different message type, and display the sum of the two values
-}
view : Model -> Html Msg
view { firstValue, secondValue } =
    Html.div []
        [ Html.div [] [ counter firstValue |> Html.map NewFirstValue ]
        , Html.div [] [ counter secondValue |> Html.map NewSecondValue ]
        , Html.text (toString (firstValue + secondValue))
        ]


{-| Respond to new values produced by each counter by storing them in the model
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        NewFirstValue value ->
            { model | firstValue = value }

        NewSecondValue value ->
            { model | secondValue = value }


main : Program Never
main =
    Html.beginnerProgram
        { model = { firstValue = 10, secondValue = 0 }
        , view = view
        , update = update
        }
