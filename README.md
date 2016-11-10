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

This is a bit verbose, involves the kind of ugly and "stringly typed" `type'`
attribute, and I personally often forget whether it's supposed to be `checked`
or `value`, or `onCheck` or `onInput`. It's tempting to leave off the `checked`
attribute entirely and just listen for new values using `onCheck`, but this
means you have no way to initialize the checkbox to a particular value and
raises the possibility of a mismatch between your model and the view.

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

Additional arguments may be used to specify additional configuration - at a
minimum, every function accepts a list of additional attributes to apply to the
generated HTML. For example, `InputWidget.comboBox` accepts a list of HTML
attributes, a list of possible values to choose from and a function for
converting those values to strings, in addition to the currently selected value
to display.

# Examples

Let's walk through a complete example using a couple functions from this
package, starting with some module imports:

```elm
module ReadmeExample exposing (..)

import Html exposing (Html)
import Html.App as Html
import Kintail.InputWidget as InputWidget
```

Next, we'll define a simple model to represent a person (with a union type used
for possible titles), along with some associated messages:

```elm
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
```

The `update` function is pretty boring:

```elm
update : Msg -> Model -> Model
update message model =
    case message of
        NewTitle newTitle ->
            { model | title = newTitle }

        NewFirstName newFirstName ->
            { model | firstName = newFirstName }

        NewLastName newLastName ->
            { model | lastName = newLastName }
```

The interesting code is all in `view`. `InputWidget.lineEdit` takes a `String`
value to display and produces a new `String` message whenever the text is
edited. `InputWidget.comboBox` takes a list of values to populate a combo box
with, as well as the value to display as currently selected, and produces a
message with the newly-selected value whenever the selection changes.

```elm
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
```

Note how `Html.map` is used to convert (tag) the 'new value' messages produced
by each widget into a proper `Msg` value.

Finally, wrap everything up with `beginnerProgram`:

```elm
main : Program Never
main =
    Html.beginnerProgram
        { model = Model Dr "Albert" "Einstein"
        , update = update
        , view = view
        }
```

Check out the [examples](https://github.com/kintail/input-widget/tree/1.0.2/examples)
directory to see the above example in full as well as more examples of how to
use each input widget, how to define your own, and how to use them within a
standard Elm app.
