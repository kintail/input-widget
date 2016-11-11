# What is it?

This package is primarily two things:

  - A more convenient way to use `<input>`, `<select>` and `<range>` elements in
    your `view` functions without having to remember the exact combinations of
    attributes and event handlers to use. I personally often forget whether it's
    `value` or `checked` I should set on a checkbox, or whether it's the
    `onInput` or `onCheck` event I should be handling. For more complex elements
    like `<select>`, custom event handlers are required. This package handles
    those annoying details for you.
  - An experiment in developing a common pattern for working with input widgets.
    All functions in this library follow the general pattern `a -> Html a`; for
    example, the `checkbox` function has the signature
    `List (Html.Attribute Bool) -> Bool -> Html Bool`, meaning that in addition
    to a list of extra HTML attributes to apply to the resulting element, it
    accepts the current `Bool` value to display (`True` for checked, `False` for
    unchecked) and produces a message with the new `Bool` value whenever the
    checkbox is clicked. Similarly, a `lineEdit` takes a `String` to display and
    produces a new `String` as a message whenever that text is edited. This
    generally enforces good practice (since you always have to explicitly
    supply the current value to display in an input widget, it's much harder to
    get a mismatch between your model and your view) but it turns out that
    following this pattern also makes it easy to create cool things like
    [input widgets for recursive data types](https://github.com/kintail/input-widget/blob/1.0.3/examples/Recursive.elm).

# How do I use it?

To install, run

```
elm package install kintail/input-widget
```

or add

```json
"kintail/input-widget": "1.0.0 <= v < 2.0.0"
```

to your `elm-package.json`.

Check out the [package documentation](http://package.elm-lang.org/packages/kintail/input-widget/latest)
for usage details.

# Examples

Let's walk through a complete example app to prompt someone for their title,
first and last names using functions from this package and display a customized
greeting. Start with some module imports:

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

The interesting code is all in `view`:

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

As mentioned above, `InputWidget.lineEdit` takes a `String` value to display and
produces a new `String` message whenever the text is edited.
`InputWidget.comboBox` takes a list of values to populate a combo box with, as
well as the value to display as currently selected, and produces a message with
the newly-selected value whenever the selection changes. (You also have to pass
a function to turn those values into strings to display; in many cases, such as
here, you can simply use Elm's built-in `toString` function.) Note how
`Html.map` is used to convert (tag) the 'new value' messages produced by each
widget into a proper `Msg` union type value.

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

Check out the [examples](https://github.com/kintail/input-widget/tree/1.0.3/examples)
directory to see the above example in full as well as more examples of how to
use each input widget, how to define your own, and how to use them within a
standard Elm app.
