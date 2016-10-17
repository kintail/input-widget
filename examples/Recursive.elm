module Recursive exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget exposing (InputWidget)


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


defaultExpression : ExpressionType -> Expression
defaultExpression expressionType =
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


typeString : ExpressionType -> String
typeString expressionType =
    case expressionType of
        TFalse ->
            "False"

        TTrue ->
            "True"

        TAnd ->
            "And"

        TOr ->
            "Or"

        TNot ->
            "Not"


typeSelection : ExpressionType -> InputWidget.Selection ExpressionType
typeSelection expressionType =
    case expressionType of
        TFalse ->
            InputWidget.selection [] TFalse [ TTrue, TAnd, TOr, TNot ]

        TTrue ->
            InputWidget.selection [ TFalse ] TTrue [ TAnd, TOr, TNot ]

        TAnd ->
            InputWidget.selection [ TFalse, TTrue ] TAnd [ TOr, TNot ]

        TOr ->
            InputWidget.selection [ TFalse, TTrue, TAnd ] TOr [ TNot ]

        TNot ->
            InputWidget.selection [ TFalse, TTrue, TAnd, TOr ] TNot []


expressionWidget : InputWidget Expression
expressionWidget expression =
    let
        comboBox : ExpressionType -> Html Expression
        comboBox expressionType =
            InputWidget.comboBox [] typeString (typeSelection expressionType)
                |> Html.map (InputWidget.selected >> defaultExpression)
    in
        case expression of
            Constant False ->
                comboBox TFalse

            Constant True ->
                comboBox TTrue

            And firstExpression secondExpression ->
                Html.span []
                    [ Html.text "("
                    , comboBox TAnd
                    , expressionWidget firstExpression
                        |> Html.map
                            (\newFirstExpression ->
                                And newFirstExpression secondExpression
                            )
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
                    , comboBox TOr
                    , expressionWidget firstExpression
                        |> Html.map
                            (\newFirstExpression ->
                                Or newFirstExpression secondExpression
                            )
                    , expressionWidget secondExpression
                        |> Html.map
                            (\newSecondExpression ->
                                Or firstExpression newSecondExpression
                            )
                    , Html.text ")"
                    ]

            Not subExpression ->
                Html.span []
                    [ Html.text "("
                    , comboBox TNot
                    , expressionWidget subExpression |> Html.map Not
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
