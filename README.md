# What is it?

This library attempts to make it easier to use the basic HTML input widgets:
checkboxes, radio buttons, line edits, combo boxes, and sliders. This is done in
such a way that it is easy to create your own input widgets for more complex
types.

# How do I use it?

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

# Examples

Check out the `examples` directory to see examples of each input widget, how to
define your own, and how to use them within a standard Elm app.
