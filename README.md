# What is it?

This library attempts to make it easier to use the basic HTML input widgets:
checkboxes, radio buttons, line edits, combo boxes, and sliders.

Every function in the library accepts as input the current value to be
displayed, and returns as output a fragment of HTML that produces newly
entered/selected values as messages. For example, `InputWidget.checkBox` accepts
a list of HTML attributes and the current `Bool` value of the checkbox, and
returns an HTML checkbox that produces a `Bool` message with the new value
whenever the checkbox is clicked by the user.

Additional arguments may be used to specify additional configuration. For
example, `InputWidget.comboBox` accepts a list of possible values to choose from
and a function for converting those values to strings, in addition to the
currently selected value to display.

`Html.map` should be used to convert the produced messages to the message type
used by your app, and the new value should generally be stored in your model and
fed back in to the `view` function. This means that the value emitted from a
given fragment of HTML will generally become the input value used to create that
same fragment of HTML the next time your `view` function is called.

Check out the `examples` directory to see examples of using each input widget
type, as well as how to embed them within a standard Elm app.
