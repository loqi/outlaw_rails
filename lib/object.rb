class Object

  # (=>Object) Return self (or alternate if 'self' responds 'true' to blank? ).
  def or_if_blank(alt) blank? ? alt : self ; end

  # (=>Integer or =>nil) Return nil if self is nil, is all whitespace, or cannot
  # be converted to a valid integer; otherwise, return the integer.
  def to_i_or_nil(radix=10)
    return nil if blank?
    if respond_to?(:to_i)
      begin
        rval = to_i(radix)
        rescue ArgumentError
          rval = to_i
        end
      return rval if rval != 0
      end # Self contains garbage, or a valid representation of zero.
    begin
      Integer(respond_to?(:trim_whitespace) ? trim_whitespace : self)
      # The trimming is a workaround for a Ruby bug (verified in 1.8.6):
      # Integer(" 1 ") =>1; Integer(" 0") =>0; but Integer("0 ") throws exception.
    rescue ArgumentError
      nil
    end ; end

  # (=>Integer or =>nil) Return 0 if self is nil, is all whitespace, or cannot
  # be converted to a valid integer; otherwise, return the integer.
  def to_i_or_0(radix=10)
    to_i_or_nil(radix) || 0
    end

  # (=>bool) True if self can be converted to a valid integer (nil and whitespace are valid).
  def blank_or_int?(radix=10)
    return true if blank?
    !!to_i_or_nil(radix)
    end

  # (=>bool) True if self can be converted to a valid integer (nil and whitespace are valid).
  def nonblank_int?(radix=10)
    return false if blank?
    !!to_i_or_nil(radix)
    end

  # (=>Float or =>nil) Return nil if self is nil, is all whitespace, or cannot
  # be converted to a valid floating-point number; otherwise, return the number.
  def to_f_or_nil
    return nil if blank?
    begin
      Float(self)
      rescue ArgumentError
        nil
    end ; end

  # (=>Float or =>nil) Return 0.0 if self is nil, is all whitespace, or cannot
  # be converted to a valid floating-point number; otherwise, return the number.
  def to_f_or_0
    to_f_or_nil || 0.0
    end

  # (=>bool) True if self can be converted to a valid float.
  def blank_or_float?
    return true if blank?
    !!to_f_or_nil
    end

  # (=>bool) True if self can be converted to a valid float.
  def nonblank_float?
    return false if blank?
    !!to_f_or_nil
    end

  end # class Object
