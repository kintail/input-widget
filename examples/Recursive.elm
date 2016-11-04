module Recursive exposing (..)

import String
import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget


-- Expression type


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
'Or' is selected in a combo box, generate a new dummy expression
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
simply dropping the leading 'T'.
-}
typeString : ExpressionType -> String
typeString =
    toString >> String.dropLeft 1


{-| Recursively create HTML for editing a given Boolean expression.
-}
expressionWidget : Expression -> Html Expression
expressionWidget expression =
    let
        expressionTypes =
            [ TFalse, TTrue, TAnd, TOr, TNot ]

        -- Helper function for creating an expression type combo box; whenever
        -- a new expression type is selected, a new dummy expression is created
        -- that can then be further edited
        comboBox expressionType =
            InputWidget.comboBox [] typeString expressionTypes expressionType
                |> Html.map defaultExpressionForType
    in
        case expression of
            Constant False ->
                comboBox TFalse

            Constant True ->
                comboBox TTrue

            Not subExpression ->
                Html.span []
                    [ Html.text "("
                    , comboBox TNot
                    , expressionWidget subExpression |> Html.map Not
                    , Html.text ")"
                    ]

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
