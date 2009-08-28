class String

    # (=>String) Remove leading and trailing whitespace and replace all whitespace
    # runs (one or more consecutive TAB, CR, LF, or ' ') with a single ' '.
  def trim_whitespace
    tr_s(" \r\n\t", '    ').strip ; end
    # (=>String) Perform trim_whitespace "in place" on self.
  def trim_whitespace!
    replace(trim_whitespace)
    end

  def bardoc
    replace(self.split("\n").map {|lin| lin.sub(/\s*\|/,'') }.join("\n")) ; end
  alias bardoc! bardoc
  def self.bardoc(raw)
    raw.lstrip.rstrip.bardoc
    end

    # (=>Integer or =>nil) Noralize the numeric string in self AND return the integer
    # value of that number. Invalid numerics cause self = '' and return nil.
  def to_i_or_nil!(radix=10)
    rval = to_i_or_nil(radix)
    replace(rval.nil? ? '' : rval.to_s(radix))
    rval
    end

    # (=>Integer) Noralize the numeric string in self AND return the integer
    # value of that number. Invalid numerics cause self = '' and return 0 .
  def to_i_or_0!(radix=10)
    to_i_or_nil!(radix) || 0 ; end

    # (=>Float or =>nil) Noralize the numeric string in self AND return the floating-
    # point value of that number. Invalid numerics cause self = '' and return nil.
  def to_f_or_nil!
    rval = to_f_or_nil
    replace(rval.to_s)
    rval
    end

    # (=>Float) Noralize the numeric string in self AND return the floating-point
    # value of that number. Invalid numerics cause self = '' and return 0.0 .
  def to_f_or_0!
    to_f_or_nil! || 0.0 ; end

    # (=>Integer or =>nil) Load the receiver with an in-place normalization of
    # itself, and then return the integer represented by its content (or nil).
    # Given all whitespace, load '' and return nil. Given an invalid integer
    # representation, leave receiver untouched and return nil. Given a valid
    # integer, load normalized string of the integer and return that integer.
  def normalize_as_int!(radix=10)
    (replace('') ; return nil) if blank?
    rval = to_i_or_nil(radix)
    replace(rval.to_s) unless rval.nil?
    rval
    end

    # (=>Float or =>nil) Like normalize_as_int! for floating-point representations.
  def normalize_as_float!
    (replace('') ; return nil) if blank?
    rval = to_f_or_nil
    replace(rval.to_s) unless rval.nil?
    rval
    end

    # (=>String) Generate string of chars randomly chosen from a palette.
  def self.random_text(len=RANDOM_TEXT_DEFLEN, palet=RANDOM_TEXT_DEFPAL)
    return palet*len if palet.length < 2
    text = ''
    len.times { text << palet[rand(palet.length)] }
    text
    end
  RANDOM_TEXT_DEFLEN = 10
  RANDOM_TEXT_DEFPAL = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

  end # class String
