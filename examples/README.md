These examples demonstrate the use of the various input widgets. Many examples
are based on a simple version of the Elm Architecture where the model is simply
the current value displayed by an input widget, the message type is the same as
the value type (the only possible message is 'new value'), and the `update`
function is the built-in `always` function (which can be interpreted as
literally 'always update the model to be the new value'!). The code therefore
looks something like

```elm

view : Value -> Html Value
view currentValue =
    ...

main =
    Html.App.beginnerProgram
        { model = initialValue
        , view = view
        , update = always
        }
```

The `ComboBox`, `RadioButton` and `Slider` examples show relatively simple
examples of using those input widgets using the format above. The `Embedding`
example shows how to use input widgets within a more standard Elm app.

The `Custom` example shows how to define your own input widgets that follow the
`a -> Html a` pattern by using a restricted form of the Elm Architecture and the
`InputWidget.custom` function. The `Validation` example shows an alternate way
of creating functions of type `a -> Html a` by making 'clever' use of
`Html.map`.

Finally, the `Recursive` example shows how you might build input widgets for
recursive data types (in this case, arbitrarily-nested boolean expressions).
