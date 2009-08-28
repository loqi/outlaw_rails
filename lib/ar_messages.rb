module ActiveRecord
  class Errors

    # Override ActiveRecord::Errors::full_messages to provide additional functionality.
    # full_messages() returns an array of String objects representing a set of user-
    # interface-ready messages. Each message normally has a capitalized, humanized
    # version of the attribute name for which it applies, inserted into the left side of
    # the message (except 'base' attribute messages, which are left unmodified.)
    # This version of full_messages() maintains near-perfect backward compatibility by
    # mimicking the classic behavior on all message strings that do not contain a leading '^'
    # character. Such strings will have the leading ^ removed, and will not have the attrib
    # name added to the front. Instead, they'll be search for special sequences, to be
    # replaced with data. A %U% sequence means "Replace with the attribute name in all
    # UPPERCASE." %L% means "...all lowercase". %=% means "...standard Rails case (that is,
    # the exact attribute name that would've stuck in the front. Probably Uppercase on first
    # character, and otherwise lowercase).
    def full_messages
      full_msg_set = []
      @errors.each_key do |attr_name|
        @errors[attr_name].each do |raw_msg|
          attr_human = @base.class.human_attribute_name(attr_name)
          next if raw_msg.nil?
          if attr_name == "base"
            msg = raw_msg
          elsif raw_msg.first=='^'
            msg = raw_msg[1..-1]
            while (i = msg=~/\%?\%/)
              msg[i..i+2] = case msg[i+1]
                when 'U': attr_human.upcase
                when 'L': attr_human.downcase
                when '=': attr_human
                else      ''
              end ; end
          else
            msg = attr_human+' '+raw_msg.lstrip
            end
          full_msg_set << msg unless msg.blank?
          end
        end
      full_msg_set
      end

    end # class
  end # module
