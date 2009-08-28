class Hash

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
