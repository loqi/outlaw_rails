<!-- A "markdown viewer" will render this file as pretty-formatted text.
  One of your text editors or file browsers may already support it. -->

Outlaw Ruby Class Extensions
============================

The outlaw_rails plugin adds some useful new methods to the standard Ruby classes
and modules.

Extensions to Ruby `Object` Class
---------------------------------

### Instance Methods

  or_if_blank(alternate)  returns self, or alternate if self is blank
  to_f_or_0               floating-point conversion method; invalid returns 0.0
  to_f_or_nil             floating-point conversion method; invalid returns nil
  to_i_or_0(radix=10)     integer conversion method; invalid returns 0
  to_i_or_nil(radix=10)   integer conversion method; invalid returns nil
  blank_or_float?         floating-point validation method; blank is valid
  nonblank_float?         floating-point validation method; blank is invalid
  blank_or_int?(radix=10) integer validation method; blank is valid
  nonblank_int?(radix=10) integer validation method; blani is invalid

**`or_if_blank(alternate)`** => `self` or `alternate`  
Returns `self` unless `self.blank?` is true, in which case `alternate` is returned.  
If `self` does not respond to `blank?`, an exception is raised, which is very unlikely,
since Rails is thorough in implementing the `blank?` method. `nil.blank?` is always
true. `String#blank?` is equivalent to `self !~ /\S/` i.e. `true` if the String is empty
or contains only whitespace.

**`to_f_or_0`** => `Float`  
Returns `0.0` if the receiver is nil, is all whitespace, or is not a valid representation
of an Float; otherwise, returns the Float cast of self.  
See also `String#to_f_or_0!`  

**`to_f_or_nil`** => `Float` or `nil`  
Returns `nil` if the receiver is nil, is all whitespace, or is not a valid representation
of an Float; otherwise, returns the Float cast of self.  
See also `String#to_f_or_nil!`

**`to_i_or_0(radix=10)`** => `Integer`  
Returns `0` if the receiver is nil, is all whitespace, or is not a valid representation
of an Integer; otherwise, returns the Integer cast of self.  
See also  `String#to_i_or_0!`

**`to_i_or_nil(radix=10)`** => `Integer` or `nil`  
Returns `nil` if the receiver is nil, is all whitespace, or is not a valid representation
of an Integer; otherwise, returns the Integer cast of self.  
See also  `String#to_i_or_nil!`

**`blank_or_float?`** => `true` or `false`  
Returns `true` if the receiver is recognized as a valid Float representation.  
`nil` and whitespace are considered valid representations of zero.

**`nonblank_float?`** => `true` or `false`  
Returns `true` if the receiver is recognized as a valid Float representation.  
`nil` and whitespace are considered invalid.

**`blank_or_int?(radix=10)`** => `true` or `false`  
Returns `true` if the receiver is recognized as a valid Integer representation.  
`nil` and whitespace are considered valid representations of zero.

**`nonblank_int?(radix=10)`** => `true` or `false`  
Returns `true` if the receiver is recognized as a valid Integer representation.  
`nil` and whitespace are considered invalid.

Extensions to Ruby Numeric Class
--------------------------------

### Instance Methods

  cardinal_noun_phrase(singular, plural, adjective='')  natural language convenience method
  number_noun_phrase(singular, plural, adjective='')    natural language convenience method

**`cardinal_noun_phrase(singular, plural, adjective='')`**  => `String`  
This method has the same behavior as `number_noun_phrase`, except that integers
from `0` to `+19` are represented as words with leading uppercase. All other values
have identical behavior as `number_noun_phrase`. 0 is represented by "No", 1 is "One",
2 is "Two", and so on through "Nineteen".

Examples:

  -2.cardinal_noun_phrase('thing','thingz','blue')    => "-2 blue thingz"
  -1.cardinal_noun_phrase('thing','thingz','blue')    => "-1 blue thing"
  -1.0.cardinal_noun_phrase('thing','thingz','blue')  => "-1.0 blue thingz"
  0.cardinal_noun_phrase('thing','thingz','blue')     => "No blue thingz"
  1.cardinal_noun_phrase('thing','thingz','blue')     => "One blue thing"
  1.0.cardinal_noun_phrase('thing','thingz','blue')   => "1.0 blue thingz"
  2.cardinal_noun_phrase('thing','thingz','blue')     => "Two blue thingz"
  19.cardinal_noun_phrase('thing','thingz','blue')    => "Nineteen blue thingz"
  20.cardinal_noun_phrase('thing','thingz','blue')    => "20 blue thingz"

If the return value of this method is to be used in a message, but not at the start
of a sentence, you'll probably want to us something like,

  number_noun_phrase(...).downcase

**`number_noun_phrase(singular, plural, adjective='')`** => `String`  
Returns an English-language phrase built from the singular or plural noun,
the adjective, and the receiver. The phrase is in the format "{receiver}
{adjective} {singular or plural noun}", and is suitable for use in user-facing
messages. The plural noun is always used, except when the receiver is an `Integer`
(including `Bignum` and `Fixnum`) *and* its value is `-1` or `+1`.  

Examples:

  -2.number_noun_phrase('thing','thingz','blue')    => "-2 blue thingz"
  -1.number_noun_phrase('thing','thingz','blue')    => "-1 blue thing"
  -1.0.number_noun_phrase('thing','thingz','blue')  => "-1.0 blue thingz"
  0.number_noun_phrase('thing','thingz','blue')     => "0 blue thingz"
  1.number_noun_phrase('thing','thingz','blue')     => "1 blue thing"
  1.0.number_noun_phrase('thing','thingz','blue')   => "1.0 blue thingz"
  2.number_noun_phrase('thing','thingz','blue')     => "2 blue thingz"

Extensions to Ruby String Class
-------------------------------

### Instance methods

  normalize_as_float!            updates self to normalized String representation of Float
  normalize_as_int!(radix=10)    updates self to normalized String representation of Integer
  to_f_or_0!                     parses String as Float, treating invalid as 0.0
  to_f_or_nil!                   parses String as Float, treating invalid as nil
  to_i_or_0!(radix=10)           parses String as Integer, treating invalid as 0
  to_i_or_nil!(radix=10)         parses String as Integer, treating invalid as nil
  trim_whitespace                returns self, but with excessive whitespace removed
  trim_whitespace!               performes trim_whitespace on self and returns new value
  
  bardoc                         a fancy heredoc string literal helper

**`normalize_as_float!`** updates `self` and returns `Float`  
Parses the content of the receiver as an alphanumeric representation of a `Float`.
If the representation in `self` is found to be valid, the floating-point value it
represents is re-rendered into alphanumeric form and overwritten at `self`, and
that integer value is returned. If `self` is all whitespace, it becomes `""` and
`nil` is returned. If it's an invalid floating-point representation, `self` is
left untouched, and `nil` is returned.

**`normalize_as_int!(radix=10)`** updates `self` and returns `Integer` or `nil`  
Parses the content of the receiver as an alphanumeric representation of an `Integer`.
If `radix` is `10`, the representation is assumed to be decimal; if `16`, it's
hexadecimal, `2` means binary, etc. If the representation in `self` is found to be
valid, the integer value it represents is re-rendered into alphanumeric form and
overwritten at `self`, and that integer value is returned. If `self` is all
whitespace, it becomes `""` and `nil` is returned. If it's an invalid integer
representation, `self` is left untouched, and `nil` is returned.

**`to_f_or_0!`** updates `self` and returns `Float`  
Normalizes the numeric string in the receiver "in place" *and* returns the
floating-point value it represents. Invalid representations cause the receiver
to become `""` and `0` to be returned.

**`to_f_or_nil!`** updates `self` and returns `Float` or `nil`  
Normalizes the numeric string in the receiver "in place" *and* returns the
floating-point value it represents. Invalid representations cause the receiver
to become `""` and `nil` to be returned.

**`to_i_or_0!(radix=10)`** updates `self` and returns `Integer`  
Noralizes the numeric string in the receiver "in place", *and* returns the
integer value it represents. Invalid representations cause the receiver to
become `""` and `0` to be returned.

**`to_i_or_nil!(radix=10)`** updates `self` and returns `Integer` or `nil`  
Noralizes the numeric string in the receiver "in place", *and* returns the
integer value it represents. Invalid representations cause the receiver to
become `""` and `nil` to be returned.

**`trim_whitespace`** => `String`  
Returns the content of the receiver, but with all leading and trailing whitespace
removed, and all embedded whitespace changed to a single space (`" "`) character.
Whitespace is defined as any contiguous run of `" "`, `\n`, `\r`, and `\t`
characters.

**`trim_whitespace!`** => `String`  
The same behavior as `trim_whitespace`, but the receiver is overwritten
by the return value.

**`bardoc`** => `String`  
Returns a String in which any leading whitespace followed by a single pipe
symbol is stripped from each line. This is designed for use with the heredoc
syntax built into Ruby. It allows heredoc literals to be indented as any other
code, without introducing unwanted whitespace characters into the string.

Example:

  s = <<eos.bardoc
    |This is a text
    |  of the emergent
    |  bardoc system.
    |That is all.
  eos
  # s == "This is a text\n  of the emergent\n  bardoc system.\nThat is all."
  # The terminating symbol (eos) line may also be indented with s = <<-eos.bardoc

### Class methods

  bardoc                        a fancy sort of heredoc String literal
  
  random_text(length, palette)  a String of randomly-generated characters

**`String.bardoc(value)`** => String  
Returns a `String` in which `value` has had any leading whitespace followed by a
single pipe symbol stripped from each line. This is a convenient way of indenting
a multi-line string literal to the proper level in code without introducing unwanted
characters into the string.

Example:

  s = String.bardoc("
    |Sally said:
    |  See Dick run.
    ")
  # s == "Sally said:\n  See Dick run."

**`String.random_text(length=10, palette="012...9ABC...Zabc...z")`** => String  
*Note that the actual default palette is the 62 characters of upper- and lowercase
letters, and numeric characters.* Generates a string of `length` characters in length,
in which each character has been chosen at random from among the character positions
of `palette`. Multiple occurrences of same character in palette causes the frequency
of that character to increase proportionally.

Example:

  strong_password = String.random_text(12)
  # => something like "G9trPnxA3TjT"
  exes_and_wyes = String.random_text(20,"xxxxY")
  # => something like "YxxYxxYxxxxxYxxxxxxx"

Extensions to Ruby Hash Class
-----------------------------

### Instance methods

  nils_to(new_value, *keys)        returns self with nil values replaced as specified
  nils_to!(new_value, *keys)

**`nils_to(new_value, *keys)`** => `Hash`  
Returns a hash in which the elements of the receiver which have `nil` as the value
have had their value replaced by `new_value`. If `keys` is specified, only the
elements whose keys are listed in the parameter glob are affected. If `keys` is
omitted, all elements of the receiver are potentially affected.

**`nils_to!(new_value, *keys)`** => `Hash`  
Same as `nils_to`, with the receiver overwritten by the return value.

Extensions to Ruby Comparable module
------------------------------------

  Comparable#not_above(maximum)       returns self or maximum, whichever is "lesser"
  Comparable#not_below(minimum)       returns self or minimum, whichever is "greater"
  Comparable#not_outside(lim1, lim2)  returns self, or whichever lim is closest

**`not_above(ceiling)`** => `self` or `ceiling`  
Returns the receiver or `ceiling`, whichever is "lesser", using the `<` operator.

**`not_below(floor)`** => `self` or `floor`  
Returns the receiver or `floor`, whichever is "greater", using the `>` operator.

**`not_outside(lim1, lim2)`** => `self` or `lim1` or `lim2`  
Returns the receiver if it compares *between* `lim1` and `lim2`, or equal to either
limit. If the receiver is greater than both limits, the higher of the two limits is
returned. If the receiver is lower, the lower of the two limits is returned.
