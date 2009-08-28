class Hash

  # (=>Hash) A hash which is a subset of the receiver, in which the keys listed in the
  # array parameter, or parameter glob, are included, and all others are excluded. Any
  # object in the array which does not correspond to a key in the the receiver is ignored.
  def slice(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
    hash = self.class.new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
    end

  # (=>Hash) Perform slice "in place" on self and returns a Hash of what was removed.
  #   { :a=>1, :b=>2, :c=>3, :d=>4 }.slice!(:a,:b) # => { :c=>3, :d=>4 }
  def slice!(*keys)
    keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
    omit = slice(*self.keys - keys)
    hash = slice(*keys)
    replace(hash)
    omit
    end

  # (=>Hash) All elements of the receiver whose data is nil, and whose keys are
  # listed in the righthand parameter glob, will have their data replaced by the
  # object given as the leftmost parameter. If the parameter glob is empty, the
  # replacement is performed on ALL elements which contain nil values.
  def nils_to!(nv, *keys) return self if nv.nil?
    keys = select{|k,v|v.nil?}.collect{|v|v[0]} if keys.empty?
    keys.each {|k| store(k,nv) if include?(k) && fetch(k).nil? }
    self
    end
  # (=>Hash) Performs nils_to! on a duplicate of the receiver, returning that hash.
  def nils_to(nv, *keys) return self if nv.nil? || !value?(nil)
    dup.nils_to!(nv, *keys)
    end

  end # class
