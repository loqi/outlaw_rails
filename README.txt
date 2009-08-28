The Outlaw Rails plugin provides useful extensions to Ruby and Rails classes.
It's main feature is Outlaw resources, which is a fancier way of formulating
routes than the standard Rails map.resources method. It also contains a few
extensions to the Ruby classes which are handy for Rails applications, and
a slightly fancier version of the popular custom-error-message plugin.
Each of these components can be easily disabled by editing init.rb.

See doc/_introduction for an overview of what this plugin can do.

Outlaw Rails version 2.2 is optimized for use with Ruby on Rails version 2.2.

The third field of both Rails and Outlaw version numbers indicates bug fixes,
so Rails 2.2.7 would be fully compatible with Outlaw 2.2.2, or vice-versa.
Rails 2.0 and 2.1 are sufficiently similar to Rails 2.2, so as to be compatible
with Outlaw 2.2. However, Rails 2.3 introduced major changes to the routing
system, rendering Outlaw 2.2 incompatible with Rails 2.3. Look for
outlaw_rails 2.3 for use with Rails 2.3 or above.

To see all the versions of Rails you have installed, type at a terminal window,
      gem list | grep rails
If you see an old version you'd like to use, type something like,
      rails _1.2.6_ my_oldtimey_app
This will generate a Rails 1.2 app called my_oldtimey_app, which you
can then manipulate in the usual way. Of course, you need to use a Rails
version that you actually have installed. In order to install an old
version, try this,
      sudo gem install rails --version '< 2.3'
This will install whatever is the latest release of Rails 2.2.x, alongside
any other versions of Rails you have. Typing,
      rails my_newfangled_app
will always use the highest version number you have installed.

An overview of outlaw_rails is in doc/_introduction
