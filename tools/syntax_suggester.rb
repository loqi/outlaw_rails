# This script is not normally loaded as an active part of the plugin; it is used by
# certain Rake tasks. It's a code conversion tool, which a programmer might occasionally
# ask to examine Rails resources code, and generate suggested replacement syntax with
# outlaw_resources equivalents. Under normal use cases, this code is not loaded.
#
# This code is only about 90% reliable and has no tests for it.

module ActionController
  module Resources
    # These two methods are called by text-replacing their call syntax into ruby code
    # which calls resource() or resources(), and then actually executing that munged
    # code. These two methods harvest all the parameters on their way to actually
    # executing resource() or resources(), and stash the params in param_capture_ar[ix]
    def intercepted_resources_call(param_capture_ar, ix, *params, &block)
      p_copy = params.dup
      p_copy[-1] = p_copy.last.dup if p_copy.last.is_a?(Hash)
      param_capture_ar[ix] = [:resources, params]
      resources(*p_copy, &block)
      end
    def intercepted_resource_call(param_capture_ar, ix, *params, &block)
      p_copy = params.dup
      p_copy[-1] = p_copy.last.dup if p_copy.last.is_a?(Hash)
      param_capture_ar[ix] = [:resource, params]
      resource(*p_copy, &block)
      end
  end ; end # module ; module

class OutlawResourcesSyntaxSuggester
  def initialize
    @orig_syntax = ''
    @munged_syntax = ''
    @mung_hist_ar = []
    @param_capture_ar = []
    end

  # This method is intended to translate the Ruby code text representing only a single
  # resources() or resource() call to the equivalent outlaw_resources() or outlaw_resource()
  # code, which will generate functionally identical or superset routes. The code that's
  # operated on must not begin with a receiver, and must not contain more than a single
  # function call. This tool does not parse the ruby code, and so has no way of finding
  # the end of the function syntax. Instead, it actually executes an altered version of
  # the code against an ActionController::Routing::Routes.draw code block.
  def proposed_outlaw_replacement_for_a_single_resources_call(orig_syntax='') @orig_syntax = orig_syntax.chomp.strip
    ( raise ArgumentError, "Malformed request to translate a Ruby method call to Outlaw:\n#{@orig_syntax.inspect}"
      ) unless @orig_syntax =~ /^resources?(\(|\s)/
    mung_all_resource_and_resources_calls("ActionController::Routing::Routes.draw do |map|\nmap.#{@orig_syntax}\nend")
    ( raise ArgumentError, "No resource() or resources() method call detected in the Ruby code:\n#{@orig_syntax.inspect}"
      ) if @mung_hist_ar.empty?
    ( raise ArgumentError, "Must have only one map.resource() or map.resources() method call in the Ruby code:\n#{@orig_syntax.inspect}"
      ) unless @mung_hist_ar.size == 1
    # Does not detect if there's extra stuff after the end of the map.resources() calling code.
    eval_syntax(@munged_syntax, @orig_syntax)
    # At this point, @param_capture_ar contains a list of all the captured parameters.
    # Each element takes the form:
    #   [ (:resources|:resource)                                                       ,
    #     [ complete set of parameters as passed to resource() or resources() method ] ]
    # But since there's only one resource() or resources() call allowed, the array should
    # have a size of exactly one element.
    # Prepare a parellel set of translated parameters.
    raise RuntimeError, "Caused #{@param_capture_ar.size} resource calls. Only one call expected." unless @param_capture_ar.size==1
    meth_sym, orig_param_ar = @param_capture_ar[0]
    mung_pos, mung_len, orig_text = @mung_hist_ar[0]
    uses_paren = !!(@munged_syntax[mung_pos...(mung_pos+mung_len)]=~/_call\(/)
    rval = suggest_syntax_string(meth_sym, orig_param_ar, uses_paren)
    rval.gsub!(/\n( *:[\w_]+) +=> +/," \\1 => ") if rval.length < 161
    rval.gsub(/\n/,"\n  ")
    end

  # This method is similar to proposed_outlaw_replacement_for_a_single_resources_call()
  # but instead of expecting a single resource() or resources() call, it expects an entire
  # config/routes.rb script, complete with any ActionController::Routing::Routes.draw
  # syntax. It works by replacing every occurance of 'resource' or 'resources' with
  # 'intercepted_resource_call' or 'intercepted_resources_call' and then executing the
  # code, which causes the parameters to be harvested.
  def proposed_outlaw_replacement_for_an_entire_script(orig_syntax='')
    @orig_syntax = orig_syntax.freeze
    mung_all_resource_and_resources_calls(@orig_syntax) # This will cause substitution in comments and String literals too.
    eval_syntax(@munged_syntax, @orig_syntax)
    # At this point, @param_capture_ar contains a list of all the captured parameters.
    # Each element takes the form:
    #   [ (:resources|:resource)                                                       ,
    #     [ complete set of parameters as passed to resource() or resources() method ] ]
    # If the original syntax contains any nested resources or namespaces, there will be
    # a mismatch between the captured parameters and the syntax. This is because such nested
    # constructs imply options (such as :name_prefix and :path_prefix) which are passed to
    # the inner method calls, but such options are not explicitly specified in the source
    # code. Due to technical lameness, the most reliable thing we can do is insert a bunch
    # of comments at the top of the syntax sample explaining how the user can edit the code.

    # Prepare a list of explanatory text lines.
    if @param_capture_ar.length < 1 || @param_capture_ar.all? {|ar| ar.blank? }
      explanatory_ar = ['# The script has been run, and no resources() or resource() calls were encountered.']
    else # At least one code substitution is outside a comment, string literal, or skipped pathway.
      explanatory_ar = [
        '# The following syntax suggestions were generated by running this script, and intercepting any'  ,
        '# resource() and resources() calls. If the script has conditional execution paths, or builds its',
        '# parameters dynamically, you\'ll see missing suggestions, or literals instead of expressions.'  ,
        '# Please adapt these suggestions as appropriate to your design.'                                 ,
        '# --------------------------' ]
      @param_capture_ar.each_with_index do |ar,i| next if ar.blank?
        meth_sym = ar[0] ; orig_param_ar = ar[1]
        uses_paren = @mung_hist_ar[i][2].last == '('
        explanatory_ar <<
          "\# Suggestion for line #{@munged_syntax[0..(@mung_hist_ar[i][0])].scan("\n").length + 1}:" <<
          "\# #{suggest_syntax_string(meth_sym, orig_param_ar, uses_paren, true)}" <<
          '# --------------------------'
        end
      explanatory_ar <<
        '# To compare outcomes, run "rake routes" before and after editing your config/routes.rb'   <<
        '# script. To ensure an existing Rails application has what it needs, each route generated' <<
        '# by the original must also be present in the new. If you\'re writing a new application'   <<
        '# from scratch, you can safely forgo supporting classic routes by either omitting the'     <<
        '# :provide option, or by removing :classic from it. If you prefer to name your controllers'<<
        '# identical to your resources (singular), you can omit the :controller option.'
      end
    orig_syntax + "\n" + explanatory_ar.join("\n") + "\n"
    end

private

  def mung_all_resource_and_resources_calls(given_syntax)
    @munged_syntax = given_syntax.dup
    @mung_hist_ar = []
    while pos = (@munged_syntax =~ /\.(resources?)(\(|\ )/) ; pos += 1 ; found_frag = "#{meth = $1}#{delim = $2}"
      mung_at(pos, found_frag.length, "intercepted_#{meth}_call#{delim}@param_capture_ar, #{@param_capture_ar.size}, ")
      @param_capture_ar << [] ; end
    end

  def mung_at(pos, remove_len, new_frag)
    @mung_hist_ar << [ pos, new_frag.length, @munged_syntax[pos...pos+remove_len] ]
    @munged_syntax[pos...pos+remove_len] = new_frag
    end

  def eval_syntax(syntax, reportable_syntax)
    # Stash the current routes, in case the user is being dumb and running this in
    # an active instance of Rails. Under ideal conditions, the user is running this
    # code in a throwaway instance of Rails, and the routes will contain whatever
    # /config/routes.rb happens to have, but the user won't care if it's messed with.
      @orig_routes = ActionController::Routing::Routes
      @orig_optim  = ActionController::Base.optimise_named_routes
      ActionController::Base.optimise_named_routes = false
      ActionController::Routing.module_eval { remove_const :Routes } if ActionController::Routing.const_defined?(:Routes)
      ActionController::Routing.const_set(:Routes, ActionController::Routing::RouteSet.new)
    # Actually execute the munged version of the code sample we were given (and
    # hope it doesn't contain anything that shouldn't actually be run, if the user
    # is being dumb and running in an instance they care about). This has the same
    # effect as running the original code, but it copies the parameters we want.
    begin
      rval = eval(syntax)
    rescue ScriptError
      raise ArgumentError, "The Ruby code given for Outlaw translation raised an exception:\n#{reportable_syntax.inspect}\n#{$!.inspect}"
    ensure
      ActionController::Routing.module_eval { remove_const :Routes }
      ActionController::Routing.const_set(:Routes, @orig_routes) # if @orig_routes
      ActionController::Base.optimise_named_routes = @orig_optim
      end
    # Restore the route structure to how it was before the code sample was run.
    rval
    end
  def outlaw_has_many_from_classic(param)
    # => { :plur101 => [:plur102,{:plur103=>:plur104}] }
    case param
      when Hash
        rval = {}
        param.each_pair do |k,v|
          v = [v] if v.is_a?(Symbol) || v.is_a?(String) # Prevents ambiguity. Otherwise [item1,item2] looks like [singular,plural]
          rval[ k.is_a?(Symbol) ? [k.to_s.singularize.to_sym,k] : [k.to_s.singularize,k.to_s] ] = outlaw_has_many_from_classic(v)
          end
        rval
      when Array
        param.collect {|v| outlaw_has_many_from_classic(v) }
      when String
        [param.singularize, param]
      when Symbol
        [param.to_s.singularize.to_sym, param]
      else
        param
    end ; end

  def suggest_syntax_string(meth_sym, orig_param_ar, uses_paren, abridge_result=false)
    tran_param_ar = orig_param_ar.dup
    tran_options = tran_param_ar.extract_options!
    tran_param_ar.collect! do |orig_param|
      if tran_options[:singular] || tran_options[:plural]
        singu = tran_options[:singular] || (meth_sym == :resources ? orig_param.to_s.singularize : orig_param)
        plur = tran_options[:plural] || (meth_sym == :resources ? orig_param : orig_param.to_s.pluralize)
        orig_param.is_a?(Symbol) ? [singu.to_sym, plur.to_sym] : [singu.to_s, plur.to_s]
      else
        tran_param = meth_sym == :resources ? orig_param.to_s.singularize : orig_param
        orig_param.is_a?(Symbol) ? tran_param.to_sym : tran_param.to_s
      end ; end
    tran_options.delete(:singular) ; tran_options.delete(:plural)
    if tran_param_ar.size==1 && !tran_options.key?(:has_one) && !tran_options.key?(:has_many)
      tran_options = {:controller=>(tran_param_ar[0].is_a?(Array) ? tran_param_ar[0][1] : tran_param_ar[0].to_s.pluralize).to_s}.merge(tran_options)
    else
      tran_options = {:plural_controllers=>true}.merge(tran_options) ; end
    tran_options.delete(:controller) if tran_param_ar.size == 1 && tran_options[:controller].to_s == (tran_param_ar[0].is_a?(Array) ? tran_param_ar[0][0] : tran_param_ar[0]).to_s
    # Build the translated string of syntax.
    rval = "outlaw_#{meth_sym}#{uses_paren ? '(' : ' '}"
    tran_param_ar.each {|param| rval += "#{param.inspect}, " }
    rval += ":provide=>[:classic,:default]"
    unless tran_options.empty?
      rval += "#{', :controller=>'+tran_options.delete(:controller).inspect if tran_options.key?(:controller)}" +
      "#{', :plural_controllers=>'+tran_options.delete(:plural_controllers).inspect if tran_options.key?(:plural_controllers)}"
      unless abridge_result
        [:as,:requirements,:conditions,:collection,:member,:new,:name_prefix,:path_prefix,:path_names,:namespace,:shallow
          ].each {|k| rval += ", #{k.inspect}=>#{tran_options.delete(k).inspect}" if tran_options.key?(k) }
        end
      rval += ", :has_one=>#{tran_options.delete(:has_one).inspect}" if tran_options.key?(:has_one)
      rval += ", :has_many=>#{outlaw_has_many_from_classic(tran_options.delete(:has_many)).inspect}" if tran_options.key?(:has_many)
      unless tran_options.empty?
        if abridge_result
          rval += ' ... '
        else
          tran_options.each_pair {|k,v| rval += ", #{k.inspect}=>#{v.inspect}" }
          tran_options = {}
      end ; end ; end
    rval += ')' if uses_paren && !rval.blank?
    rval
    end

  end # class
