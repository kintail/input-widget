# What is it?

When I first started working on small Elm apps I found it a bit annoying (having
very little experience with HTML) to have to remember the various combinations
of HTML attributes needed to build up basic input widgets. For example, a simple
checkbox view function might look like:

```elm
import Html
import Html.Attributes

type Msg
    = NewValue Bool

checkbox : Bool -> Html Msg
checkbox currentValue =
    Html.input
        [ Html.Attributes.type' "checkbox"
        , Html.Attributes.checked currentValue
        , Html.Attributes.onCheck NewValue
        ]
        []
```

This is a bit verbose, involves the kind of ugly and "stringly typed"
`type' "checkbox"` attribute, and I personally often forget whether it's
supposed to be `checked` or `value`. It's tempting to just leave off the
`checked` attribute entirely and just listen for new values using `onCheck`, but
this means you have no way to initialize the checkbox to a particular value (and
raises the possibility of an initial mismatch between your model and the view).

This library consists of a set of view functions that make it easier to use the
basic HTML input widgets: checkboxes, radio buttons, line edits, combo boxes,
and sliders. The main goals are to avoid having to remember a bunch of
attributes, and be able to follow a consistent pattern: provide the current
value to display, and listen for updated values.

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
