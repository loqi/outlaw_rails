module ActionController
 module OutlawResources

  def outlaw_resources(*entities, &block)
    map_resources(:collection_resource, *entities, &block)
    end
  def outlaw_resource(*entities, &block)
    map_resources(:singleton_resource, *entities, &block)
    end

  def outlaw_resources_descriptor_array(*entities, &block)
    DryMapper.new.relay_map_resources(:collection_resource, *entities, &block)
    end
  def outlaw_resource_descriptor_array(*entities, &block)
    DryMapper.new.relay_map_resources(:singleton_resource, *entities, &block)
    end

  def outlaw_resources_ruby_code_array(*entities, &block)
    ruby_from_drymap(outlaw_resources_descriptor_array(*entities, &block))
    end
  def outlaw_resource_ruby_code_array(*entities, &block)
    ruby_from_drymap(outlaw_resource_descriptor_array(*entities, &block))
    end

  def map_from_route_descriptor_array(rdescr_ar)
    rdescr_ar.each do |r|
      r[:name] ? named_route(r[:name], r[:path], r[:options]) : connect(r[:path], r[:options])
    end ; end

private

  def ruby_from_drymap(r_ar)
    r_ar.collect {|r|
      (r[:name] ? "named_route(#{r[:name].inspect}, " : 'connect(') + "#{r[:path].inspect}, #{(r[:options]||{}).inspect})" }
    end
  # Simulates just enough of ActionController::Routing::RouteSet::Mapper methods, so as to
  # build an array of route descriptors through a relay call to map_resources().
  class DryMapper < ActionController::Routing::RouteSet::Mapper
    def initialize()                         @ar = [] ; end
    def connect(path, options={})            @ar << {:path=>path.to_s,:options=>options} ; end
    def named_route(name, path, options={})  connect(path,options) ; @ar.last[:name] = name.to_s ; end
    def relay_map_resources(what_kind, *entities, &block)
      map_resources(what_kind, *entities, &block) # This will map to a DryMapper instead of a Mapper.
      @ar ; end
    end # class

  def map_resources(what_kind, *entities, &block)
    orig_opts = entities.extract_options!
    entities.each do |entity|
      options = orig_opts.dup ; singular = plural = nil
      if entity.is_a?(Array) && entity.size==2 && entity.all? {|el| el.is_a?(String) || el.is_a?(Symbol) || el.nil? }
        singular, plural = entity
      elsif entity.is_a?(String) || entity.is_a?(Symbol)
        singular, plural = options[:singular], entity if options[:singular] && !options[:plural]
        singular, plural = entity, options[:plural]  if !options[:singular] &&  options[:plural]
        singular ||= entity
      else
        raise ArgumentError, "Invalid parameter: #{entity.inspect}" ; end
      singular ||= options[:singular] || ( plural ? plural.to_s.singularize : entity )
      plural ||= options[:plural] || singular.to_s.pluralize
      r = OutlawResource.new(self, singular.to_s, (what_kind == :singleton_resource ? nil : plural.to_s), options.dup)
      with_options(r.codeblock_nest_options, &block) if block_given?
      end ; end

  class OutlawResource #:nodoc:
    def initialize(map, singular, plural=nil, options={})
      @is_singleton = plural.nil?
      @map = map # Should be an ActionController::Routing::RouteSet::Mapper object
      @options = options.nils_to('',:name_prefix,:outlaw_name_prefix,:classic_name_prefix,:path_prefix,:outlaw_path_prefix,:classic_path_prefix)
      @singular = singular.to_s
      @plural   = (plural || @options[:plural] || @singular.pluralize).to_s
      @controller = "#{@options[:namespace]}#{@options[:controller] or @options[:plural_controllers] ? @plural : @singular }"
      @plural = @singular if @is_singleton
      @conditions = @options[:conditions] || {}
      id_reqt = ( @reqs_without_id = (@options[:requirements]||{}).dup ).delete(:id) || /[^#{Routing::SEPARATORS.join}]+/
      @reqs_with_id = @reqs_without_id.merge({:id=>id_reqt})
      r_seps = "\\#{(Routing::SEPARATORS).join('\\')}\\\/" # Routing pathfield separators (escaped), plus extra '/' to be sure it's there.
      @path_id_regex = Regexp.new("[#{r_seps}]:id[#{r_seps}]")
      @a_sep           = ActionController::Base.resource_action_separator # ';' in old Rails, as in "thingies/edit;5". '/' in newer Rails.
      @default_path_ar = ActionController::Base.resources_path_names # {:edit=>'edit', :new=>'new', ...}

      # If :collection is specified for a singleton, roll it into the :member option
      if @is_singleton && @options[:collection]
        @options[:member] = @options[:collection].merge(@options[:member]||{})
        @options.delete(:collection)
        end

      # Set up Outlaw name and path elements:
      o_path_seg = @options[:as] || @singular
      @o_id_name_suffix     = opt_or_default_s(:id_name_suffix, '_id')
      @o_nest_id_name_suffix= opt_or_default_s(:nest_id_name_suffix, @o_id_name_suffix)
      @o_root_name_suffix   = opt_or_default_s(:root_name_suffix, '_root')
      @o_id_root_name_suffix= opt_or_default_s(:id_root_name_suffix, '')
      @o_f_name_suffix      = opt_or_default_s(:f_name_suffix, '_f')
      @o_name_prefix = (@options[:outlaw_name_prefix] || @options[:name_prefix] || @options[:o_nest_name_prefix]).to_s
      @o_path_prefix = (@options[:outlaw_path_prefix] || @options[:path_prefix] || @options[:o_nest_path_prefix]).to_s
      @o_shallow_path_prefix = "#{ @o_path_prefix unless @options[:shallow] && !@is_singleton }"
      @o_shallow_name_prefix = "#{ @o_name_prefix unless @options[:shallow] && !@is_singleton }"
      @o_nest_path_prefix = "#{@o_shallow_path_prefix}/#{o_path_seg}/:#{@singular}_id"
      @o_nest_name_prefix = "#{@o_shallow_name_prefix}#{@singular}#{@o_nest_id_name_suffix unless @is_singleton}_"
      @o_collec_path = "#{@o_path_prefix}/#{o_path_seg}"
      if @is_singleton
        @o_member_path = @o_nest_path_prefix = @o_collec_path
      else
        x = "#{@o_shallow_path_prefix}/#{o_path_seg}/:"
        @o_member_path     = "#{x}id"
        @o_nest_path_prefix= "#{x}#{@singular}_id"
        end

      # Set up classic (backward compatibility) name and path elements (this section's repetition is okay):
      c_path_seg = @options[:as] || (@is_singleton ? @singular : @plural)
      @c_name_prefix = (@options[:classic_name_prefix] || @options[:name_prefix] || @options[:c_nest_name_prefix]).to_s
      @c_path_prefix = (@options[:classic_path_prefix] || @options[:path_prefix] || @options[:c_nest_path_prefix]).to_s
      @c_shallow_path_prefix = "#{ @c_path_prefix unless @options[:shallow] && !@is_singleton }"
      @c_shallow_name_prefix = "#{ @c_name_prefix unless @options[:shallow] && !@is_singleton }"
      @c_nest_path_prefix = "#{@c_shallow_path_prefix}/#{c_path_seg}/:#{@singular}_id"
      @c_nest_name_prefix = "#{@c_shallow_name_prefix}#{@singular}_"
      @c_collec_path = "#{@c_path_prefix}/#{c_path_seg}"
      if @is_singleton
        @c_member_path = @c_nest_path_prefix = @c_collec_path
      else
        x = "#{@c_shallow_path_prefix}/#{c_path_seg}/:"
        @c_member_path     = "#{x}id"
        @c_nest_path_prefix= "#{x}#{@singular}_id"
        end

      # Build :provide and :omit support.
      @mass_mnem = {
        'none'   => [] ,
        'default'=> (@is_singleton ? [] : ['index'             ]) + ['restful'] ,
        'classic'=> (@is_singleton ? [] : ['classic_collection']) + ['classic_new','classic_member','classic_edit'] ,
        'restful'=> (@is_singleton ? [] : ['collection'        ]) + ['new','member','edit'] ,
        'pretty' => (@is_singleton ? [] : ['index'             ]) + ['new','create','show','edit','update','destroy'] ,
        'outlaw' => ['restful','pretty'] ,
        'all'    => ['classic','outlaw'] }
      @std_quad_by_mnem = { # Elemental mnemonics when @is_singleton==true
        'classic_member'=>[:show,:create,:update,:destroy], 'classic_new'=>[:new,nil,nil,nil], 'classic_edit'=>[:edit,nil,nil,nil],
        'member'=>[:show,:create,:update,:destroy], 'new'=>[:new,nil,nil,nil], 'create'=>[nil,:create,nil,nil],
        'show'=>[:show,nil,nil,nil], 'edit'=>[:edit,nil,nil,nil], 'update'=>[nil,nil,:update,nil], 'destroy'=>[nil,nil,nil,:destroy] }
      unless @is_singleton # Adjust elemental mnemonics when @is_singleton==false
        @std_quad_by_mnem['classic_collection'] = [:index,:create,nil,nil] ; @std_quad_by_mnem['classic_member'] = [:show,nil,:update,:destroy]
        @std_quad_by_mnem[        'collection'] = [:index,:create,nil,nil] ; @std_quad_by_mnem[        'member'] = [:show,nil,:update,:destroy]
        @std_quad_by_mnem['index'] = [:index,nil,nil,nil] ; end
      @user_action_ar_h = {}
      [:collection,:member,:new].each {|actn_div| augment_actions(actn_div, @options[actn_div]) }
      @want = {} # Keyed by individual-route mnemonics, not paired-route or mass-route mnemonics.
      want(@options[:provide] || [:default])
      omit(@options[:omit] || [])
      # Build "learn" variables:
      @rdescr_by_name = {}
      @name_pair_ar = []

      # Build the collision-prone route names, removing duplicates.
      @c_member_name_nof = "#{@c_shallow_name_prefix}#{@singular}"
      @c_member_name_f   = c_f_from_nof(@c_member_name_nof)
      @o_member_name_nof = "#{@o_shallow_name_prefix}#{@singular}#{@is_singleton ? @o_root_name_suffix : (@o_id_name_suffix + @o_id_root_name_suffix)}"
      @o_member_name_f   = o_f_from_nof(@o_member_name_nof)
      @o_member_name_nof = '' if want?(:classic_member_nof) && @o_member_name_nof==@c_member_name_nof
      @o_member_name_f   = '' if want?(:classic_member_f  ) && @o_member_name_f  ==@c_member_name_f
      @c_collec_name_nof = "#{@c_name_prefix}#{@plural}#{'_index' if @singular==@plural}"
      @c_collec_name_f   = c_f_from_nof(@c_collec_name_nof)
      @o_collec_name_nof = "#{@o_name_prefix}#{@singular}#{@o_root_name_suffix}"
      @o_collec_name_f   = o_f_from_nof(@o_collec_name_nof)
      @o_collec_name_nof = '' if want?(:classic_collection_nof) && @o_collec_name_nof==@c_collec_name_nof
      @o_collec_name_f   = '' if want?(:classic_collection_f  ) && @o_collec_name_f  ==@c_collec_name_f
      @o_index_name_nof  = "#{@o_name_prefix}#{@singular}_index"
      @o_index_name_f    = o_f_from_nof(@o_index_name_nof)
      @o_index_name_nof  = '' if want?(:classic_collection_nof) && @o_index_name_nof==@c_collec_name_nof
      @o_index_name_f    = '' if want?(:classic_collection_f  ) && @o_index_name_f  ==@c_collec_name_f

      # Learn the classic routes.
      (@user_action_ar_h['collection']||[]).sort.each {|action|
        learn_classic_pair("#{action}_#{@c_name_prefix}#{@plural}", "#{@c_collec_path}#{@a_sep}#{action}", "classic_#{action}_collection") }
      learn_pair(@c_collec_name_nof, @c_collec_path, @c_collec_name_f, 'classic_collection')
      c_new_path = "#{@c_collec_path}/#{action_path_frag(:new)}"
      learn_classic_pair("new_#{@c_name_prefix}#{@singular}", c_new_path, 'classic_new')
      (@user_action_ar_h['new']||[]).sort.each {|action|
        learn_classic_pair("#{action}#{'_new' unless action=='new'}_#{@c_name_prefix}#{@singular}", "#{c_new_path}#{@a_sep+action.to_s unless action=='new'}", "classic_#{action}_new") }
      (@user_action_ar_h['member']||[]).sort.each {|action|
        learn_classic_pair("#{action}_#{@c_shallow_name_prefix}#{@singular}", "#{@c_member_path}#{@a_sep}#{action_path_frag(action)}", "classic_#{action}_member") }
      learn_pair(@c_member_name_nof, @c_member_path, @c_member_name_f, 'classic_member')
      learn_classic_pair("edit_#{@c_shallow_name_prefix}#{@singular}", "#{@c_member_path}#{@a_sep}#{action_path_frag(:edit)}", 'classic_edit')

      # Learn the outlaw routes.
      (@user_action_ar_h['collection']||[]).sort.each {|action|
        learn_outlaw_pair("#{@o_name_prefix}#{@singular}_#{action}", "#{@o_collec_path}#{@a_sep}#{action}", "#{action}_collection") }
      learn_pair(@o_collec_name_nof, @o_collec_path, @o_collec_name_f, 'collection')
      learn_pair(@o_index_name_nof, "#{@o_collec_path}/#{action_path_frag(:index)}", @o_index_name_f, 'index')
      o_new_path = "#{@o_collec_path}/#{action_path_frag(:new)}"
      learn_outlaw_pair("#{@o_name_prefix}#{@singular}_new", o_new_path, 'new')
      (@user_action_ar_h['new']||[]).sort.each {|action|
        learn_outlaw_pair("#{@o_name_prefix}#{@singular}#{'_new' unless action=='new'}_#{action}", "#{o_new_path}#{@a_sep+action.to_s unless action=='new'}", "#{action}_new") }
      learn_outlaw_pair("#{@o_name_prefix}#{@singular}_create", "#{@o_collec_path}/#{action_path_frag(:create )}", 'create')
      (@user_action_ar_h['member']||[]).sort.each {|action|
        learn_outlaw_pair("#{@o_shallow_name_prefix}#{@singular}#{@o_id_name_suffix unless @is_singleton}_#{action}", "#{@o_member_path}#{@a_sep}#{action}", "#{action}_member") }
      learn_pair(@o_member_name_nof, @o_member_path, @o_member_name_f, 'member')
      learn_outlaw_pair("#{@o_shallow_name_prefix}#{@singular}#{@o_id_name_suffix unless @is_singleton}_show"   ,"#{@o_member_path}#{@a_sep}#{action_path_frag(:show   )}",'show')
      learn_outlaw_pair("#{@o_shallow_name_prefix}#{@singular}#{@o_id_name_suffix unless @is_singleton}_edit"   ,"#{@o_member_path}#{@a_sep}#{action_path_frag(:edit   )}",'edit')
      learn_outlaw_pair("#{@o_shallow_name_prefix}#{@singular}#{@o_id_name_suffix unless @is_singleton}_update" ,"#{@o_member_path}#{@a_sep}#{action_path_frag(:update )}",'update')
      learn_outlaw_pair("#{@o_shallow_name_prefix}#{@singular}#{@o_id_name_suffix unless @is_singleton}_destroy","#{@o_member_path}#{@a_sep}#{action_path_frag(:destroy)}",'destroy')

      # Perform the actual mapping of the learned routes.
      @name_pair_ar.each do |name_pair|
        [:get,:post,:put,:delete].each_with_index do |verb, verb_i|
          name_pair.each do |name| next unless name and rdescr = @rdescr_by_name[name] and action = (quad = rdescr[:quad])[verb_i]
            path = rdescr[:path] ; name = rdescr.delete(:name)  # Use name only once.
            opts = { :controller=>@controller, :action=>action.to_s, :conditions=>@conditions.dup }
            if verb_i==0 && quad.all? {|a| a==action }
              rdescr[:quad] = [nil,nil,nil,nil] # Skip the other three iterations (eventually).
            else
              opts[:conditions].merge!(:method=>verb) ; end # Specify a verb unless all four actions are identical.
            opts.merge!( "/#{path}/" =~ @path_id_regex ? @reqs_with_id : @reqs_without_id )
            map_one_route!(name, path, opts)
        end ; end ; end

      # Map the :has_many and :has_one associations:
      map_has_many_associations(@options.delete(:has_many)) if @options[:has_many]
      Array(@options[:has_one]).each {|assoc| @map.outlaw_resource(assoc, inline_nest_options) }
      end # def initialize

    def codeblock_nest_options # Used by nested code blocks, which may contain calls to outlaw_resource() , resource() , outlaw_resources() , or resources() .
      @options.slice(:shallow,:namespace,:provide,:omit,:plural_controllers,:f_name_suffix,:id_name_suffix,:nest_id_name_suffix,:root_name_suffix,:id_root_name_suffix).merge({
        :o_nest_path_prefix=>@o_nest_path_prefix, :o_nest_name_prefix=>@o_nest_name_prefix, :c_nest_path_prefix=>@c_nest_path_prefix, :c_nest_name_prefix=>@c_nest_name_prefix })
      end

private

    # (=>boolean) true means "the route had already been mapped once before"
    # Keeps its own running list of mapped routes in @mapped_route_ar .
    def previously_mapped!(name, path, opts)
      if opts[:conditions].blank? || opts[:conditions][:method].blank?
        return [:get,:post,:put,:delete].all? {|verb| previously_mapped!(name, path, opts.merge(:conditions=>{:method=>verb})) }
        end # If any one of the component verbs are not already listed, consider this route *not* previously mapped.
      @mapped_route_ar ||= [] # A list of all previously mapped routes, with verbless routes listed as four verbed routes.
      route_identifier = name.to_s+'~'+path.to_s+'~'+opts.inspect
      return true if @mapped_route_ar.include?(route_identifier)
      @mapped_route_ar << route_identifier
      false
      end

    # Map the route described by the parameters. If it's previously been mapped, don't map a second copy.
    def map_one_route!(name, path, opts)
      return if previously_mapped!(name, path, opts)
      name.blank? ? @map.connect(path, opts) : @map.named_route(name, path, opts)
      end

    # (=>String) If @options[op_sym] does not exist, return default. If it does exist, even if ==nil , return its value (to_s).
    def opt_or_default_s(op_sym, default) (@options.key?(op_sym) ? @options[op_sym] : default).to_s ; end

    def inline_nest_options # Used by the in-line associations (:has_one and :has_many)
      codeblock_nest_options.merge(@options.slice(:has_many))
      end

    # Given an action Symbol, returns a String representing the innermost element of a path appropriate to referencing that action.
    def action_path_frag(action)
      ( ( @options[:path_names][action.to_sym] if @options[:path_names].is_a?(Hash) ) || @default_path_ar[action.to_sym] || action ).to_s
      end

    def map_has_many_associations(assoc_param)
      if assoc_param.is_a?(Hash)
        assoc_param.each_pair do |item, has_many|
          @options[:has_many] = has_many # Recurse into the hash
          map_has_many_associations([item]) # :plur becomes [:plur] ; [:singu,:plur] becomes [[:singu,:plur]]
          end
      elsif assoc_param.is_a?(Array) # Probably an array of arrays, i.e. [ item1plural, [item2singular, item2plural], item3plural, {hash...} ]
        assoc_param.each do |assoc|
          if assoc.is_a?(Hash)
            map_has_many_associations(assoc) ; next
          elsif assoc.is_a?(Array)
            raise ArgumentError, "Array must have one singular and one plural: #{assoc.inspect}" unless assoc.size==2
          # elsif assoc.is_a?(Symbol) || assoc.is_a?(String)
          #   assoc = [assoc, assoc.to_s.pluralize] # Unlike standard Rails map.resources(), singular naming is the convention.
            end
          @map.outlaw_resources(assoc, inline_nest_options)
          end
        elsif assoc_param.is_a?(Symbol) || assoc_param.is_a?(String)
          map_has_many_associations([assoc_param.to_s])
        else
          raise ArgumentError, "Invalid parameter: #{assoc_param.inspect} is a #{assoc_param.class}."
        end
      end

    # Given an array of elemental mnemonics, mass mnemonics, and/or arrays of those, resolve them
    # down to constituent elemental mnemonics, and record into the @want hash, for when the time comes
    # to do the route mapping. (Anything not listed in @want gets passed over during the "learn" stage.)
    def want(*mn_arar) mn_arar.flatten.each {|big_mn| @want.merge!(hash_of_mnem(big_mn)) } end
    def omit(*mn_arar) mn_arar.flatten.each {|big_mn| hash_of_mnem(big_mn).each_key {|mn| @want.delete(mn) } } ; end
    def want?(mn) !!@want[mn] ; end
    def want_all?(*mn_ar) mn_ar.all? {|mn| @want[mn] } ; end

    # => {elemental_route_mnem=>action_quad,...} Given a mnemonic, which could be an elemental or mass
    # mnemonic, it is unpacked to its elemental constituents, and a Hash is returned with each elemental
    # route as keys, and action quads as a value. An unrecognized mnemonic raises ArgumentError.
    def hash_of_mnem(mnem) mnem = mnem.to_s
      q = @std_quad_by_mnem[k = mnem] and return { "#{mnem}_f"=>q, "#{mnem}_nof"=>q }
      mnem.last(2)=='_f'   and q = @std_quad_by_mnem[k = mnem[0..-3]] and return { mnem=>q }
      mnem.last(4)=='_nof' and q = @std_quad_by_mnem[k = mnem[0..-5]] and return { mnem=>q }
      mnem_ar = @mass_mnem[k] or raise ArgumentError, "Invalid mnemonic symbol - #{mnem.inspect}"
      rval = {}
      suff = (suflen = mnem.length - k.length).zero? ? '' : mnem.last(suflen) # Rails bug: last(0). Fixed in outlaw_extensions.
      mnem_ar.each {|mn| rval.merge!(hash_of_mnem(mn+suff)) }
      rval
      end

    # Given 'collection'|'member'|'new' and a hash {action=>(:get|:post|:put|:delete|:any|[of those]),...}
    # representing the augmentation request, assimilate that request into the instance variables
    # in such a way as to cause them to be learned as specified.
    def augment_actions(actn_div, verbset_by_action) actn_div = actn_div.to_s
      return if !verbset_by_action || verbset_by_action.empty?
      @user_action_ar_h[actn_div] = []
      verbset_by_action.each_pair do |action, verbset| action = action.to_sym
        @user_action_ar_h[actn_div] << action.to_s
        verbset = [verbset].flatten.collect {|v| v = v.to_sym
          raise ArgumentError, "Invalid HTTP verb: #{v}" unless [:get,:post,:put,:delete,:any].include?(v)
          v }
        quad = [nil,nil,nil,nil]
        if verbset.include?(:any)
          quad = [action,action,action,action]
        else
          [:get,:post,:put,:delete].each_with_index {|v,i| quad[i] = action if verbset.include?(v) } ; end
        @std_quad_by_mnem["classic_#{action}_#{actn_div}"] = quad ; @mass_mnem["classic"] << "classic_#{action}_#{actn_div}"
        @std_quad_by_mnem["#{action}_#{actn_div}"] = quad.dup ; @mass_mnem["restful"] << "#{action}_#{actn_div}"
      end ; end

    def c_f_from_nof(name_nof) "formatted_#{name_nof}" ; end
    def o_f_from_nof(name_nof) "#{name_nof}#{@o_f_name_suffix}" ; end
    def learn_classic_pair(name_nof, path_nof, mnem) learn_pair(name_nof, path_nof, c_f_from_nof(name_nof), mnem) ; end
    def learn_outlaw_pair( name_nof, path_nof, mnem) learn_pair(name_nof, path_nof, o_f_from_nof(name_nof), mnem) ; end
    def learn_pair(name_nof, path_nof, name_f, pair_mnem) name_nof = name_nof.to_s ; name_f = name_f.to_s
      mnem_nof = "#{pair_mnem}_nof" ; mnem_f = "#{pair_mnem}_f" ; name_pair = [nil,nil]
      ( name_pair[0] = name_nof ; @rdescr_by_name[name_nof] = assimilate!(name_nof, {:name=>name_nof, :path=>path_nof.to_s   ,:quad=>clean_quad(@want[mnem_nof])}) ) if @want[mnem_nof]
      ( name_pair[1] = name_f   ; @rdescr_by_name[name_f  ] = assimilate!(name_f, {:name=>name_f,:path=>"#{path_nof}.:format",:quad=>clean_quad(@want[mnem_f  ])}) ) if @want[mnem_f  ]
      @name_pair_ar << name_pair unless name_pair==[nil,nil]
      end
    def assimilate!(old_rname, new_rdescr) # Consolodates action quads (new trumps old).
      old_rdescr = @rdescr_by_name[old_rname] and 0.upto(3) {|i| new_rdescr[:quad][i] ||= old_rdescr[:quad][i] }
      new_rdescr ; end
    def clean_quad(q) (q||[nil,nil,nil,nil]).collect {|a| a ? a.to_s : nil } ; end # Dup & make all quad elements String or nil.

    end # class

 end ; end # module ; module

class ActionController::Routing::RouteSet::Mapper
  include ActionController::OutlawResources
  end
