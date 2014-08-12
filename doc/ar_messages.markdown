<!-- A "markdown viewer" will render this file as pretty-formatted text.
  One of your text editors or file browsers may already support it. -->

Customizable Active Record Validation Messages
==============================================

The `full_messages` method has been overridden by custom code which provides a finer
degree of control for Active Record validation error messages. Supports all the
functionality of the popular `custom_error_message` plugin by David Easley
(Found at `http://rubyforge.org/projects/custom-error-message/`)

Normally each Active Record validation message inserts a capitalized, humanized version
of the attribute name for which it applies (except `base` attribute messages, which are
left unmodified.) With the `outlaw_rails` plugin, you can embed character codes into
your user message strings to get more control over the final result, with near-perfect
backward compatibility. All of your existing messages will still work, unless they contain
a leading `^` character.

A leading `^` means *"Don't insert the attribute name into the front of this message, and
replace any `%` sequences with the appropriate data."* Message literals with a leading `^`
will be rendered without that `^`, and if there are any `%?%` sequences present anywhere
in the literal (where `?` means any one character), those sequences will be replaced with
data.

  %U%  Replace with the humanized attribute name in all UPPERCASE
  %L%  Replace with the humanized attribute name in all lowercase"
  %=%  ...unmodified case (probably first letter uppercase and all others lowercase)

So for example, the model code...

  validates_format_of :screen_name, :with => /[^\?]/ ,
    :message => "^Invalid %L%. %=% fields may not contain a question mark."

...will present to the user as a validation message something like...

  Invalid screen name. Screen name fields may not contain a question mark.
