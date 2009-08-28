# -*- coding: utf-8 -*-

# This is the behavior script for Outlaw Resources code migration tools.
#
# Here we test the tools that suggest new Ruby code syntax to replace
# old syntax, usually in the /config/routes.rb script. It tests the ability
# of OutlawResourcesSyntaxSuggester to accurately suggest syntax to replace
# individual lines of code, as well as entire config/routes.rb scripts.
#
# The main verification technique is to actually run the original and suggested
# code against temporary ActionController::Routing::RouteSet objects and then
# compare the routes that each actually generated. The test passes if they are
# effectively identical sets, or if the suggested syntax generates a superset
# of the original syntax.

require "#{File.dirname(__FILE__)}/spec_helper_resources"
require "#{File.dirname(__FILE__)}/../tools/syntax_suggester"

def before_each_line_translation_tool
  before_each
  @got_newfangled_routes = @scratch_routes
  @got_oldtimey_routes = ActionController::Routing::RouteSet.new
  @syntax_tool = OutlawResourcesSyntaxSuggester.new
  end
def before_each_batch_translation_tool
  before_each
  @got_newfangled_routes = @scratch_routes
  @got_oldtimey_routes = ActionController::Routing::RouteSet.new
  @syntax_tool = OutlawResourcesSyntaxSuggester.new
  end

def translate_line(oldtimey_syntax)
  @syntax_tool.proposed_outlaw_replacement_for_a_single_resources_call(oldtimey_syntax)
  end
# Generate newfangled syntax from an individual line of code. Execute both versions. Verify
# the routes generated by the old syntax are a subset of those made by new syntax.
def it_goes_both_ways(oldtimey_syntax)
  it oldtimey_syntax do
    (newfangled_syntax = translate_line(oldtimey_syntax)).should be_string_beginning_with('outlaw_resour')
    @got_oldtimey_routes.draw   {|map| eval("map.#{oldtimey_syntax  }") }
    @got_newfangled_routes.draw {|map| eval("map.#{newfangled_syntax}") }
    @got_oldtimey_routes.should be_routes_all_present_in(@got_newfangled_routes, newfangled_syntax)
    end
  end
# given a string of option syntax, call it_goes_both_ways() against both singleton and collection resources.
def it_goes_four_ways(opt_str=nil)
  it_goes_both_ways("resources :plur1#{opt_str}")
  it_goes_both_ways("resource :singu1#{opt_str}")
  end

describe ResourcesController, "translation tool correctly translates lines of code\n", :type=>:controller do
  before :all  do before_all ; end
  before :each do before_each_line_translation_tool ; end
  after  :each do after_each ; end
  after  :all  do after_all ; end

  it_goes_four_ways('')
  it_goes_both_ways('resources :plur1, :plur2') ; it_goes_both_ways('resource :singu1, :singu2')
  it_goes_four_ways(', :conditions=>{:subdomain=>"app"}')
  it_goes_four_ways(', :requirements=>{:id=>/[0-9]\.[0-9]\.[0-9]/}')
  it_goes_four_ways(', :path_prefix=>"/thread/:thread_id", :requirements => {:thread_id=>/[0-9]\.[0-9]\.[0-9]/}')
  it_goes_four_ways(', :path_prefix=>"/thread/:thread_id"')
  opt_str = ':path_prefix=>"/thread/:thread_id"' ; it_goes_both_ways("resources(:plur1, :plur2, #{opt_str})") # This one tests parenthesized syntax too.
                                                   it_goes_both_ways("resource(:singu1, :singu2, #{opt_str})")
  it_goes_four_ways(', :name_prefix=>"post_"')
  it_goes_four_ways(', :as=>"plur2"')
  it_goes_four_ways(', :as=>"plur2", :path_prefix=>"/thread/:thread_id", :requirements=>{:thread_id=>/[0-9]\.[0-9]\.[0-9]/}')

  it_goes_both_ways('resources :plur1, :singular=>:singu202')

  it_goes_four_ways(', :collection=>{"a"=>:get,"b"=>:put,:c=>:post,"d"=>:delete}')
  it_goes_four_ways(', :collection=>{"a"=>:get,:b=>:put,"c"=>:post,"d"=>:delete}, :path_prefix=>"/threads/:thread_id", :name_prefix=>"thread_"')
  it_goes_four_ways(', :member=>{:mark=>[:put,:post]}, :path_names=>{:new=>"nuevo"}')
  it_goes_four_ways(', :member=>{:mark=>[:put,:post], :unmark=>[:get,:put]}')
  it_goes_four_ways(', :collection=>{:search=>[:get,:post]}, :member=>{:toggle=>[:get,:post]}')
  it_goes_four_ways(', :new=>{:pleview=>:post}')
  it_goes_four_ways(', :new=>{:preview=>:post}, :path_prefix=>"/threads/:thread_id", :name_prefix=>"thread_"')
  it_goes_four_ways(', :new=>{:preview=>:post}, :path_prefix=>"/threads/:thread_id", :name_prefix=>"thread_"')

  # Note that :only and :except are meant to reduce the number of routes. This spec script verifies
  # that the outlaw_resources syntax generates a superset of the resources syntax. That means that if
  # the Outlaw methods are somehow imposing looser restrictions than the Rails methods, the problem
  # will get by these tests. But since Outlaw syntax for :only and :except is compatible with standard
  # Rails syntax, these two parameters may just be carried over as-is. Consequently, these tests
  # will never fail, so they're commented out.
  # it_goes_four_ways(', :only=>[:show,:new]')
  # it_goes_four_ways(', :except=>[:create,:destroy]')
  # it_goes_four_ways(', :only=>[:show,:new], :except=>[:create,:destroy]')

  it_goes_four_ways(', :has_many=>[:plur101,:plur102]')
  it_goes_four_ways(', :has_many=>[:plur101,:plur102], :shallow=>true')
  it_goes_four_ways(', :has_many=>{:plur101=>[:plur102,{:plur103=>:plur104}]}')
  it_goes_four_ways(', :has_one=>:singu101')
  it_goes_four_ways(', :has_one=>:singu101, :shallow=>true')

  opt_str = "    :collection => {:rss=>:get, :reorder=>:post, :csv=>:post},\n" +
            "    :member     => {:rss=>:get, :atom=>:get, :upload=>:post, :fix=>:post},\n" +
            "    :new        => {:preview=>:get, :draft=>:get}"
  it_goes_both_ways("resources :plur1,\n#{opt_str}" )
  it_goes_both_ways("resource  :singu1,\n#{opt_str}")

  it_goes_four_ways(', :namespace=>"back_office/"')

  end # describe

def be_string_beginning_with(exp_left_side) BeStringBeginningWith.new(exp_left_side) ; end
  # Passes if the receiver is a String, and the content of that String is at least
  # as long as 'exp_left_side' and the left side is an exact match.
class BeStringBeginningWith
  def initialize(exp_left_side) ; @exp_left_side = exp_left_side ; @hot_sz = @exp_left_side.size ; end
  def matches?(big_string) @got_obj = big_string
    big_string.is_a?(String) && big_string.size >= @hot_sz && big_string[0...@hot_sz]==@exp_left_side ; end
  def failure_message() "Expected a String beginning with #{@exp_left_side.inspect}, but got:\n#{@got_obj.inspect}" ; end
  end

def be_routes_all_present_in(big_routeset, syntax='(not specified)') BeRoutesAllPresentIn.new(big_routeset,syntax) ; end
  # Passes if the routeset object that is the receiver contains no routes that are
  # not also present in 'big_routeset'. Does not verify that they are listed in the
  # same order, on the assumption that either order is reasonable. If any route does
  # not specify an HTTP verb, the other routeset must either have the same no-verb
  # route, or must list all four (GET,POST,PUT,DELETE) flavors of that route. If
  # there are multiple routes with the same URL path, any of those identically-pathed
  # routes may be the one with the route name.
class BeRoutesAllPresentIn
  def initialize(big_routeset, syntax)
    @big_route_ar = route_descriptor_ar(big_routeset) ; @syntax = syntax ; @msg_ar = [] ; end
  def matches?(little_routeset)
    little_route_ar = route_descriptor_ar(little_routeset)
    name_wid, path_wid = name_wid_path_wid(@big_route_ar, little_route_ar)
    suspect_ar = []
    little_route_ar.each_with_index {|exp_descr,i| suspect_ar << i unless @big_route_ar.include?(exp_descr) }
    return true if suspect_ar.empty?
    # At this point, suspect_ar will have a list of indexes into little_route_ar, where that route
    # is not identical to a route in @big_route_ar . They'll be checked further: All functionality
    # in little_route_ar must also be present in @big_route_ar , with a few exotic exceptions.
    # If a route by a different name is present in @big_route_ar, and another route with
    # the same name and path is also present, the route passes. Also, a route which does not
    # specify an HTTP verb in little_route_ar is considered fulfilled only if all four verb
    # flavors are present in @big_route_ar . However a verbless route in @big_route_ar matches
    # any verbed route in 'little' . Furthermore, all names in 'little' must be present in
    # 'big', but not necessarily vice-versa.
    bad_ar = []
    suspect_ar.each {|lit_i| bad_ar << lit_i unless route_passes?(little_route_ar[lit_i]) }
    return true if bad_ar.empty?
    @msg_ar << "All routes generated by the original Rails syntax (*not found):"
    @msg_ar += printable_routeset_ar(:got, little_route_ar, bad_ar, name_wid, path_wid)
    @msg_ar << "The translation tool recommends this Outlaw replacement syntax:"
    @msg_ar << @syntax
    @msg_ar << "All routes generated by the Outlaw replacement syntax:"
    @msg_ar += printable_routeset_ar(:got, @big_route_ar, [], name_wid, path_wid)
    @msg_ar << "Not all the Rails routes appear among the Outlaw routes, as they should."
    false
    end
  def failure_message() @msg_ar.join("\n") ; end
  def route_passes?(given_route)
    if given_route[:verb].blank?
      r = given_route.dup
      return ['GET','POST','PUT','DELETE'].all? {|v| r[:verb] = v ; route_passes?(r) } ; end
    # At this point given_route[:verb] is guaranteed not to be blank.
    want_path = given_route[:path]
    similar_route_ar = @big_route_ar.select {|r| r[:path]==want_path }
    return false if similar_route_ar.empty?
    return false unless given_route[:name].blank? || similar_route_ar.any? {|r| r[:name]==given_route[:name] }
    similar_route_ar.any? {|r| # At this point, we don't need to look at name or verb. Everything else must match.
      r[:verb].blank? || r[:verb]==given_route[:verb] and r.all? {|k,v| v==given_route[k] || k==:verb || k==:name } }
    end
  end
