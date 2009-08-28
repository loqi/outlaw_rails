# This script provides common code for testing the integrity of the Outlaw Ruby class
# extensions, which are in scripts found in lib/ whose names end in "_ext.rb".

require "#{File.dirname(__FILE__)}/spec_helper_all"

# TODO: this should probably be in a module.

class MethodTester
  attr_reader :abbr_syntax
  def initialize(orig_obj, meth_syntax, expec_reply)
    begin
      @scratch_obj = orig_obj.dup
      rescue TypeError
        @scratch_obj = orig_obj
      end
    @abbr_syntax  = "#{abbr(orig_obj)}.#{meth_syntax}"  # Suitable for user messages.
    @live_syntax  = "@scratch_obj.#{meth_syntax}"       # Suitable for execution.
    @expec_reply  = expec_reply
    @err_msgs     = []    # Non-empty indicates at least one error has been detected.
    end
  def copasetic?
    actual_reply = eval(@live_syntax)
    (@err_msgs << "Unexpected return value:\nRUBY CODE: #{@abbr_syntax}\n EXPECTED: #{abbr(@expec_reply)}\n      GOT: #{abbr(actual_reply)}"
      ) if actual_reply.class != @expec_reply.class || actual_reply != @expec_reply
    @err_msgs.empty?
    end
  def big_error_message() @err_msgs.join("\n")+"\n"  ; end
  def abbr_expec_reply()  abbr(@expec.reply)    ; end
protected
  def abbr(obj,mx_len=300)
    mx_len = 10 if mx_len<10
    rval = obj.inspect
    rval = obj.class.to_s+':'+obj.to_s.inspect if rval[0..0]=='#'
    return rval if rval.length<=mx_len
    r_len = mx_len/3 ; l_len = mx_len-r_len-3
    rval[0..l_len]+'...'+rval[-r_len..-1]
  end ; end

class IdempotentMethodTester < MethodTester
  def initialize(orig_obj, meth_syntax, expec_reply)
    super(orig_obj, meth_syntax, expec_reply)
    @scratch_obj.freeze  # Detects receiver writes. Also verifies frozen objects get service.
    end
  def copasetic?
    begin
      super
      rescue TypeError
        @err_msgs << "#{@abbr_syntax} is modifying the receiver."
      end
    @err_msgs.empty?
  end ; end

class MutatorMethodTester < MethodTester
  def initialize(orig_obj, meth_syntax, expec_reply, expec_obj)
    super(orig_obj, meth_syntax, expec_reply)
    @expec_obj = expec_obj
    end
  def copasetic?
    super
    ( @err_msgs << "Receiver set to unexpected value:\nRUBY CODE: #{@abbr_syntax}\n EXPECTED: #{abbr(@expec_obj)}\n      GOT: #{abbr(@scratch_obj)}."
      ) if @scratch_obj.class != @expec_obj.class || @scratch_obj != @expec_obj
    @err_msgs.empty?
  end ; end

def be_copasetic() BeCopasetic.new ; end
class BeCopasetic
  def matches?(meth_tester)
    @meth_tester = meth_tester
    @meth_tester.copasetic?
    end
  def failure_message
    @meth_tester.big_error_message
  end ; end

def be_copasetic_batch() BeCopaseticBatch.new ; end
class BeCopaseticBatch
  def matches?(meth_testers)
    @flunkers = []
    @meth_testers = meth_testers
    meth_testers.each do |meth_tester|
      @flunkers << meth_tester unless meth_tester.copasetic?
      end
    @flunkers.empty?
    end
  def failure_message
    "#{@flunkers.size} out of #{@meth_testers.size} tests flunked:\n\n#{ @flunkers.collect {|x| x.big_error_message }.join("\n") }"
  end ; end

# def it_good_method(meth_tester, descrip)
#   it descrip do meth_tester.should be_copasetic end
#   end
# 
# def it_good_ro(orig_obj, meth_syntax, expec_reply) # "'it'-verify a valid read-only method call."
#   it_good_method( IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply) ,
#     "#{orig_obj.inspect}.#{meth_syntax} returns #{expec_reply.inspect} without side effect." )
#   end
# 
# def it_good_rw(orig_obj, meth_syntax, expec_reply, expec_obj) # "'it'-verify a valid read-write method call."
#   it_good_method( MutatorMethodTester.new(orig_obj, meth_syntax, expec_reply, expec_obj) ,
#     "#{orig_obj.inspect}.#{meth_syntax} becomes #{expec_obj.inspect} and returns #{expec_reply.inspect}." )
#   end

def it_good_batch(meth_tester_batch, descrip)
  it "#{meth_tester_batch.size} tests: #{descrip}" do
    meth_tester_batch.should be_copasetic_batch
  end ; end
