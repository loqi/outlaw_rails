# This script provides common code for all the spec scripts of the plugin.
# It is loaded by the other spec_helper_***.rb scripts.

ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'

alias :doing :lambda

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = "#{RAILS_ROOT}/spec/fixtures/"
  end
