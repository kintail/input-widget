module Recursive exposing (..)

import String
import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget


-- Expression type ('business logic', not tied to the UI)


type Expression
    = Constant Bool
    | And Expression Expression
    | Or Expression Expression
    | Not Expression


evaluate : Expression -> Bool
evaluate expression =
    case expression of
        Constant value ->
            value

        And firstExpression secondExpression ->
            evaluate firstExpression && evaluate secondExpression

        Or firstExpression secondExpression ->
            evaluate firstExpression || evaluate secondExpression

        Not subExpression ->
            not (evaluate subExpression)



-- Expression widget


type ExpressionType
    = TFalse
    | TTrue
    | TAnd
    | TOr
    | TNot


{-| Create a 'default'/'dummy' expression of the given type. For example, if
'Or' is selected in a combo box, this is used to generate a new dummy expression
'False Or False' that can then be edited further.
-}
defaultExpressionForType : ExpressionType -> Expression
defaultExpressionForType expressionType =
    case expressionType of
        TFalse ->
            Constant False

        TTrue ->
            Constant True

        TAnd ->
            And (Constant False) (Constant False)

        TOr ->
            Or (Constant False) (Constant False)

        TNot ->
            Not (Constant False)


{-| Convert an `ExpressionType` to a string by using the default `toString` and
then dropping the leading 'T'.
-}
typeString : ExpressionType -> String
typeString =
    toString >> String.dropLeft 1


{-| Recursively create HTML for editing a given Boolean expression.
-}
expressionWidget : Expression -> Html Expression
expressionWidget expression =
    let
        -- List of expression types to display in combo boxes.
        expressionTypes =
            [ TFalse, TTrue, TAnd, TOr, TNot ]

        -- Helper function for creating an expression type combo box: whenever
        -- a new expression type is selected, a new dummy expression is created
        -- that can then be further edited.
        comboBox expressionType =
            InputWidget.comboBox [] typeString expressionTypes expressionType
                |> Html.map defaultExpressionForType
    in
        case expression of
            -- The input widget for the constant false value is simply a combo
            -- box set to 'False'.
            Constant False ->
                comboBox TFalse

            -- The input widget for the constant false value is simply a combo
            -- box set to 'False'.
            Constant True ->
                comboBox TTrue

            -- For a negated expression, the input widget is a combo box set to
            -- 'Not' and then another expression widget for the negated
            -- subexpression. If the subexpression widget is edited, it will
            -- emit a message with the new subexpression; `Html.map Not` is used
            -- to negate that subexpression to form the updated top-level `Not`
            -- expression. (If the combo box is edited instead, the entire
            -- top-level expression will be wiped out and replaced by a 'dummy'
            -- expression of the newly selected type.)
            Not subExpression ->
                Html.span []
                    [ Html.text "("
                    , comboBox TNot
                    , expressionWidget subExpression |> Html.map Not
                    , Html.text ")"
                    ]

            -- Editing an 'And' expression is similar to 'Not' but a bit more
            -- complex. Note how `Html.map` is used to combine a new value for
            -- one operand with the existing value of the other operand to
            -- create a new top-level `And` expression.
            And firstExpression secondExpression ->
                Html.span []
                    [ Html.text "("
                    , expressionWidget firstExpression
                        |> Html.map
                            (\newFirstExpression ->
                                And newFirstExpression secondExpression
                            )
                    , comboBox TAnd
                    , expressionWidget secondExpression
                        |> Html.map
                            (\newSecondExpression ->
                                And firstExpression newSecondExpression
                            )
                    , Html.text ")"
                    ]

            -- 'Or' is pretty much the same as 'And'. Note that since there is
            -- no mapping used on the combo box, editing the expression type
            -- completely blows away the current expression and replaces it with
            -- a new dummy one of the selected type; a more sophisticated
            -- implementation might do something like retain the same left and
            -- right hand operands if an 'Or' is switched to an 'And'.
            Or firstExpression secondExpression ->
                Html.span []
                    [ Html.text "("
                    , expressionWidget firstExpression
                        |> Html.map
                            (\newFirstExpression ->
                                Or newFirstExpression secondExpression
                            )
                    , comboBox TOr
                    , expressionWidget secondExpression
                        |> Html.map
                            (\newSecondExpression ->
                                Or firstExpression newSecondExpression
                            )
                    , Html.text ")"
                    ]



-- Program


{-| Show the current expression as well as that expression evaluated to a
Boolean value.
-}
view : Expression -> Html Expression
view expression =
    Html.div []
        [ Html.div [] [ expressionWidget expression ]
        , Html.div [] [ Html.text (toString (evaluate expression)) ]
        ]


main : Program Never
main =
    Html.beginnerProgram
        { model = Or (Constant False) (Constant True)
        , view = view
        , update = always
        }
