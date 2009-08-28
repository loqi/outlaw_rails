<!-- A "markdown viewer" will render this file as pretty-formatted text.
  One of your text editors or file browsers may already support it. -->

Outlaw Rails Plugin for Ruby on Rails 2.3
=========================================

The outlaw_rails plugin contains a collection of features useful for building
Ruby on Rails web applications. Each major feature group is briefly described in
the sections below, and has its own detailed documentation file describing it.

Outlaw Rails version 2.3 is optimized for use with Ruby on Rails version 2.3.
See README.txt for a discussion of how to get your Rails and Outlaw versions
to match.

Supplemental methods for Ruby classes
-------------------------------------

Adds convenience methods for conditioning and standardizing user-input and database
fields. Introduces methods for converting strings to floats or integers, plugging
default values into strings, building grammatically correct user messages,
standardizing whitespace, generating random character strings, confining integers
within limits, and manipulating Hash data structures. Also adds an "indentable
heredoc" literal syntax to clean up the indentation zone of files that use heredocs.

Details in `doc/ruby_classes`

Fancy RESTful Route Generators
------------------------------

Generate prettier, saner, more consistent route names and paths than what you
get with `map.resources` and `map.resource`. Free your URLs and route names from
pluralization. Maintain perfect backward compatibility with classic Rails routes
(including pluralization), so you can continue to provide the old routes to your
existing code while migrating to a better way at your own pace.

Details in `doc/resources`

Customizable Active Record Validation Messages
----------------------------------------------

Get more control over the error messages presented to users by the Active Record
validators. Omit field names, or insert them into the body of the message, by
putting special character sequences into the message string.

Details in `doc/ar_messages`

This code fully emulates David Easley's `custom-err-message` (or
`custom-error-message`) plugin, adding more features. It does not cohabitate with
that plugin. If you would like to use that plugin instead of Outlaw Rails custom
validation messages, you'll need to edit `plugins/outlaw_rails/init.rb` such that
`require 'ar_messages'` is not executed.

Version 2.3 differs from version 2.2 in the following ways:

* The `:only` and `:except` options have been added to the `outlaw_resource` and
`outlaw_resources` methods. These options were not present in pre-2.3 Rails.
* Combined functionality of the "format" from "non-format" routes. Previously,
two flavors of each route were used to implement formatted and default routes.
Version 2.3 combines the two routes into one.
