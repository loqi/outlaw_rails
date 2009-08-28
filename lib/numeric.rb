class Numeric

  # (=>String) Builds an English-language phrase around the reciver numeric value, using
  # the adjective and either the singular or the plural noun supplied as parameters.
  # This phrase will never use the singular noun, except when the receiver is an Integer
  # (including Fixnum and Bignum) with a value of either +1 or -1.
  # Examples:
  # -2.number_noun_phrase('thing','thingz','blue')    => "-2 blue thingz"
  # -1.number_noun_phrase('thing','thingz','blue')    => "-1 blue thing"
  # -1.0.number_noun_phrase('thing','thingz','blue')  => "-1.0 blue thingz"
  # 0.number_noun_phrase('thing','thingz','blue')     => "0 blue thingz"
  # 1.number_noun_phrase('thing','thingz','blue')     => "1 blue thing"
  # 1.0.number_noun_phrase('thing','thingz','blue')   => "1.0 blue thingz"
  # 2.number_noun_phrase('thing','thingz','blue')     => "2 blue thingz"
  def number_noun_phrase(singular, plural, adjective='')
    "#{to_s} #{adjective} #{ (integer? and self.abs==1) ? singular : plural }".trim_whitespace
    end

  # (=>String) Same as number_noun_phrase, except the numbers 0..+19 are represented as
  # words, but only if the recevier is an Integer (including Fixnum and Bignum).
  # Examples:
  # -2.cardinal_noun_phrase('thing','thingz','blue')    => "-2 blue thingz"
  # -1.cardinal_noun_phrase('thing','thingz','blue')    => "-1 blue thing"
  # -1.0.cardinal_noun_phrase('thing','thingz','blue')  => "-1.0 blue thingz"
  # 0.cardinal_noun_phrase('thing','thingz','blue')     => "No blue thingz"
  # 1.cardinal_noun_phrase('thing','thingz','blue')     => "One blue thing"
  # 1.0.cardinal_noun_phrase('thing','thingz','blue')   => "1.0 blue thingz"
  # 2.cardinal_noun_phrase('thing','thingz','blue')     => "Two blue thingz"
  # 19.cardinal_noun_phrase('thing','thingz','blue')    => "Nineteen blue thingz"
  # 20.cardinal_noun_phrase('thing','thingz','blue')    => "20 blue thingz"
  def cardinal_noun_phrase(singular, plural, adjective='')
    return number_noun_phrase(singular,plural,adjective) if !integer? || self<0 || self >=CARDINALS.length
    "#{CARDINALS[self]} #{adjective} #{ (self.abs==1) ? singular : plural }".trim_whitespace
    end
  CARDINALS = %w{ No One Two Three Four Five Six Seven Eight Nine Ten Eleven
    Twelve Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen }

  end # class Integer
