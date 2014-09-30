# Syntax migration tools

Though there's no requirement to change anything about your `config/routes.rb`
script, or to stop using the `resources` methods that come with Rails, if
you'd like to start enjoying the benefits of Outlaw resources, you can easily
switch one or more of your `resource` or `resources` method calls to a
backward-compatible `outlaw_resources` call which produces all the same
("classic") routes, plus a parallel set of new Outlaw routes.

By choosing a backward-compatible syntax in your `routes.rb` script, none of
your existing Rails code will break. You can begin writing new code to take
advantage of the Outlaw style resource routes alongside the resource routes
provided to keep your legacy code happy.

For very detailed documentation on Outlaw routes, see `doc/resources`

Here are some Rake tasks to help you get started.

## Help with Migrating a `config/routes.rb` script

There's a Rake task, which will scan a `config/routes.rb` script, and suggest syntax
to replace it.

  rake outlaw:syntax:routes_rb

**This task does not write to your `routes.rb` file.**

It works by actually executing your `routes.rb` script, intercepting the parameters
supplied to `resource` and `resources` method calls, and then restoring your Rails
state as before. After it discovers the parameters supplied to each relevant method,
it proposes new syntax for you to consider. The proposed new syntax is meant to
deliver all the same routes, plus a parallel set of Outlaw routes. The output is
sent to `stdout` (the console) for display. All the usual piping techniques are
applicable.

example:

  rake outlaw:syntax:routes_rb > temp/routes.rb

This will create a new Ruby script file and fill it with the existing code of
`config/routes.rb`, plus an extended comment footer explaining how to switch it to
Outlaw resources.

A human is expected to make the actual edits to the code.

## Translating individual lines of code

There's an interactive task, which will accept user input of a Ruby expression, and
will output suggested replacement code. The proposed expression is meant to provide all
the same routes to support legacy code, plus a parallel set of routes for new code.

  rake outlaw:syntax:interactive

To use it, type the command above, and when prompted, type a call expression of a
`resource` or `resources` method call. Each time you give it a new line of code, it
will suggest compatible Outlaw code which maps the appropriate superset of routes.

To exit, give it a blank line.
