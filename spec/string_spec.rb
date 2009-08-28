# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/spec_helper_meth_test"

class RandTextTester
  attr_reader :err_msg
  def initialize(palet='a')
    palet = 'a' if palet.to_s.length < 1
    @size = palet.length
    @palet = palet
    @string_c = 0
    @char_c = 0
    @stat_a = Array.new(@size, 0)
    @err_msg = ''
    end
  def analyze!(text, expec_len)
    loc_stat_a = Array.new(@size, 0)
    loc_stat_lim = text.length * 2 / @size + 5 # May need to use standard deviation
    if text.length != expec_len
      @err_msg = "Randomized string...\n\"#{text}\"\n...has a length of #{text.length}, instead of the expected #{expec_len}\n"
      return false
      end
    text.each_char do |cstr|
      c = cstr[0]
      if i = @palet.index(cstr)
        @stat_a[i] += 1
        if (loc_stat_a[i] += 1) > loc_stat_lim
          @err_msg = "Randomized string...\n#{msgable_string(text)}\n...appears not to be random. More than #{loc_stat_lim} occurances of #{msgable_char(c)}\n"
          return false
          end
      else
        @err_msg = "Randomized string...\n\"#{msgable_string(text)}\"\n...contains #{msgable_char(c)}, which is not in palette...\n\"#{@palet}\"\n"
        return false
      end ; end
    @string_c += 1
    @char_c += text.length
    return true
    end
  def stats_within(mx_deviation)
    mn_val = mx_val = @stat_a[0]
    lc_chr = mc_chr = @palet[0]
    @stat_a.each_index do |i|
      v = @stat_a[i]
      lc_chr, mn_val = @palet[i], v if v < mn_val
      mc_chr, mx_val = @palet[i], v if v > mx_val
      end
    return true if mx_val-mn_val <= mx_deviation
    @err_msg = "Randomized string statistics are suspicious.\n" +
               "After #{@string_c} strings totalling #{@char_c} characters.\n" +
               "------------------------------------\n"         +
               "#{msgable_char_stats}\n"                        +
               "------------------------------------\n"         +
               "Low: #{mn_val} of #{msgable_char(lc_chr)}\n"    +
               "High: #{mx_val} of #{msgable_char(mc_chr)}\n"   +
               "Difference: #{mx_val-mn_val}\n"                 +
               "Allowed deviation: #{mx_deviation}"
    return false
    end
private
  def msgable_char(c)
    sprintf("['%c'%04X]", c, c)
    end
  def msgable_string(str)
    return '['+str+']' if str.length< 400
    '['+str[0..200]+"......"+str[-200..-1]+']'
    end
  def msgable_char_stats
    s = ""
    @stat_a.each_index do |i|
      s += sprintf('%10s~%3d ', msgable_char(@palet[i]), @stat_a[i])
      s += (i % 4 == 3) ? "\n" : ' '
      end
    s
    end
  end # class

def analyze_and_approve(str,len) AnalyzeAndApprove.new(str,len) ; end
class AnalyzeAndApprove
  def initialize(str,len) @str = str ; @len = len ; end
  def matches?(random_text_tester)
    @tester = random_text_tester
    @tester.analyze!(@str,@len) ; end
  def failure_message() @tester.err_msg ; end
  end

def have_stats_within(mx_deviation) HaveStatsWithin.new(mx_deviation) ; end
class HaveStatsWithin
  def initialize(mx_deviation) @mx_deviation = mx_deviation ; end
  def matches?(random_text_tester)
    @tester = random_text_tester
    @tester.stats_within(@mx_deviation) ; end
  def failure_message() @tester.err_msg ; end
  end

describe String do

  # Test String#trim_whitespace! and String#trim_whitespace :
  plain_testers = [] ; mutator_testers = []
  [ [""                            , ""                 ] ,
    [" "                           , ""                 ] ,
    [" a"                          , "a"                ] ,
    ["a  "                         , "a"                ] ,
    ["\t\n\r\n  a\n\t  \t\r a  \t" , "a a"              ] ,
    ["a"                           , "a"                ] , # Unlike many Ruby methods, trim_whitespace! never returns nil.
    ["   This\tis   a test."       , "This is a test."  ]
  ].each do |orig_obj, expec_reply|
    plain_testers << IdempotentMethodTester.new(orig_obj, 'trim_whitespace' , expec_reply             )
    mutator_testers <<  MutatorMethodTester.new(orig_obj, 'trim_whitespace!', expec_reply, expec_reply)
    end
  it_good_batch(plain_testers, "trim_whitespace returns correct String without side effect")
  it_good_batch(mutator_testers, "trim_whitespace! returns correct String and updates receiver")

  # Test String#to_i_or_nil! and String#to_i_or_0! :
  or_nil_testers = [] ; or_0_testers = []
  [ [nil, ""               ,     "" ,   nil   ,   0   ] ,
    [nil, "\t\n\r\n "      ,     "" ,   nil   ,   0   ] ,
    [nil, "0"              ,    "0" ,     0   ,   0   ] ,
    [nil, "0."             ,     "" ,   nil   ,   0   ] ,
    [nil, "."              ,     "" ,   nil   ,   0   ] ,
    [nil, ".0"             ,     "" ,   nil   ,   0   ] ,
    [nil, "\t.0\n"         ,     "" ,   nil   ,   0   ] ,
    [nil, "0.0"            ,     "" ,   nil   ,   0   ] ,
    [nil, "\t00\n "        ,    "0" ,     0   ,   0   ] ,
    [nil, ".00"            ,     "" ,   nil   ,   0   ] ,
    [nil, "00."            ,     "" ,   nil   ,   0   ] ,
    [nil, "  000.000 "     ,     "" ,   nil   ,   0   ] ,
    [nil, "1"              ,    "1" ,     1   ,   1   ] ,
    [nil, "1."             ,    "1" ,     1   ,   1   ] ,
    [nil, ".1"             ,     "" ,   nil   ,   0   ] ,
    [nil, "0.1"            ,     "" ,   nil   ,   0   ] ,
    [nil, "00.170"         ,     "" ,   nil   ,   0   ] ,
    [nil, ".4"             ,     "" ,   nil   ,   0   ] ,
    [nil, "0.4"            ,     "" ,   nil   ,   0   ] ,
    [nil, "00.499"         ,     "" ,   nil   ,   0   ] ,
    [nil, "00.500"         ,     "" ,   nil   ,   0   ] ,
    [nil, "00.999"         ,     "" ,   nil   ,   0   ] ,
    [nil, "257"            ,  "257" ,   257   , 257   ] ,
    [nil, "1.3e1"          ,    "1" ,     1   ,   1   ] ,
    [nil, "Testing."       ,     "" ,   nil   ,   0   ] ,
    [ 16, "1a"             ,   "1a" ,    26   ,  26   ] ,
    [ 16, "1f"             ,   "1f" ,    31   ,  31   ] ,
    [ 16, "1g"             ,    "1" ,     1   ,   1   ] ,
    [ 11, "1a"             ,   "1a" ,    21   ,  21   ] ,
    [ 11, "1b"             ,    "1" ,     1   ,   1   ] ,
    [ 10, "10"             ,   "10" ,    10   ,  10   ] ,
    [ 10, "1a"             ,    "1" ,     1   ,   1   ]
  ].each do |radix, orig_obj, expec_obj, expec_i_o_n_reply, expec_i_o_0_reply|
    meth_syntax = 'to_i_or_nil!' + (radix.nil? ? '' : '('+radix.to_s+')')
    or_nil_testers << MutatorMethodTester.new(orig_obj, meth_syntax, expec_i_o_n_reply, expec_obj)
    meth_syntax = 'to_i_or_0!'   + (radix.nil? ? '' : '('+radix.to_s+')')
    or_0_testers   << MutatorMethodTester.new(orig_obj, meth_syntax, expec_i_o_0_reply, expec_obj)
    end
  it_good_batch(or_nil_testers, "to_i_or_nil! returns correct value and updates receiver")
  it_good_batch(or_0_testers  ,   "to_i_or_0! returns correct value and updates receiver")

  # Test String#to_f_or_nil! and String#to_f_or_0! :
  or_nil_testers = [] ; or_0_testers = []
  [ [ ""               , ""           ,   nil   ,   0.0   ] ,
    [ "\t\n\r\n "      , ""           ,   nil   ,   0.0   ] ,
    [ "Testing."       , ""           ,   nil   ,   0.0   ] ,
    [ "."              , ""           ,   nil   ,   0.0   ] ,
    [ "\t.0\n"         , "0.0"        ,   0.0   ,   0.0   ] ,
    [ ".44"            , "0.44"       ,   0.44  ,   0.44  ] ,
    [ "0"              , "0.0"        ,   0.0   ,   0.0   ] ,
    [ " 0"             , "0.0"        ,   0.0   ,   0.0   ] ,
    [ "0 "             , "0.0"        ,   0.0   ,   0.0   ] ,
    [ "0 "             , "0.0"        ,   0.0   ,   0.0   ] ,
    [ "0 "             , "0.0"        ,   0.0   ,   0.0   ] ,
    [ " 0 "            , "0.0"        ,   0.0   ,   0.0   ] ,
    [ " 0 "            , "0.0"        ,   0.0   ,   0.0   ] ,
    [ " 0 "            , "0.0"        ,   0.0   ,   0.0   ] ,
    [ "\t00\n "        , "0.0"        ,   0.0   ,   0.0   ] ,
    [ " 1x "           , ""           ,   nil   ,   0.0   ] ,
    [ "1"              , "1.0"        ,   1.0   ,   1.0   ] ,
    [ "1."             , ""           ,   nil   ,   0.0   ] ,
    [ "257"            , "257.0"      , 257.0   , 257.0   ] ,
    [ "1.3e1"          , "13.0"       ,  13.0   ,  13.0   ] ,
    [ "1.3e2"          , "130.0"      , 130.0   , 130.0   ] ,
    [ "1a"             , ""           ,   nil   ,   0.0   ]
  ].each do |orig_obj, expec_obj, expec_f_o_n_reply, expec_f_o_0_reply|
    meth_syntax = 'to_f_or_nil!'
    or_nil_testers << MutatorMethodTester.new(orig_obj, meth_syntax, expec_f_o_n_reply, expec_obj)
    meth_syntax = 'to_f_or_0!'
    or_0_testers   << MutatorMethodTester.new(orig_obj, meth_syntax, expec_f_o_0_reply, expec_obj)
    end
  it_good_batch(or_nil_testers, "to_f_or_nil! returns correct value and updates receiver")
  it_good_batch(or_0_testers  ,   "to_f_or_0! returns correct value and updates receiver")

  # Test String#normalize_as_int!
  method_testers = []
  [ [nil, ""               ,          "" ,   nil  ] ,
    [nil, "\t\n\r\n "      ,          "" ,   nil  ] ,
    [nil, "0"              ,         "0" ,     0  ] ,
    [nil, "0."             ,        "0." ,   nil  ] ,
    [nil, "."              ,         "." ,   nil  ] ,
    [nil, ".0"             ,        ".0" ,   nil  ] ,
    [nil, "\t.0\n"         ,    "\t.0\n" ,   nil  ] ,
    [nil, "0.0"            ,       "0.0" ,   nil  ] ,
    [nil, "\t00\n "        ,         "0" ,     0  ] ,
    [nil, ".00"            ,       ".00" ,   nil  ] ,
    [nil, "00."            ,       "00." ,   nil  ] ,
    [nil, "  000.000 "     ,"  000.000 " ,   nil  ] ,
    [nil, "1"              ,         "1" ,     1  ] ,
    [nil, "1."             ,         "1" ,     1  ] ,
    [nil, ".1"             ,        ".1" ,   nil  ] ,
    [nil, "0.1"            ,       "0.1" ,   nil  ] ,
    [nil, "00.170"         ,    "00.170" ,   nil  ] ,
    [nil, ".4"             ,        ".4" ,   nil  ] ,
    [nil, "0.4"            ,       "0.4" ,   nil  ] ,
    [nil, "00.499"         ,    "00.499" ,   nil  ] ,
    [nil, "00.500"         ,    "00.500" ,   nil  ] ,
    [nil, "00.999"         ,    "00.999" ,   nil  ] ,
    [nil, "257"            ,       "257" ,   257  ] ,
    [nil, "1.3e1"          ,         "1" ,     1  ] ,
    [nil, "Testing."       ,  "Testing." ,   nil  ] ,
    [ 16, "1a"             ,        "26" ,    26  ] ,
    [ 16, "1F"             ,        "31" ,    31  ] ,
    [ 16, "1g"             ,         "1" ,     1  ] ,
    [ 11, "1A"             ,        "21" ,    21  ] ,
    [ 11, "1b"             ,         "1" ,     1  ] ,
    [ 10, "10"             ,        "10" ,    10  ] ,
    [ 10, "1a"             ,         "1" ,     1  ]
  ].each do |radix, orig_obj, expec_obj, expec_reply|
    meth_syntax = 'normalize_as_int!' + (radix.nil? ? '' : '('+radix.to_s+')')
    method_testers << MutatorMethodTester.new(orig_obj, meth_syntax, expec_reply, expec_obj)
    end
  it_good_batch(method_testers, "normalize_as_int! returns correct value and updates receiver")

  # Test String#normalize_as_float!
  method_testers = []
  [ [ ""               , ""           ,   nil   ] ,
    [ "\t\n\r\n "      , ""           ,   nil   ] ,
    [ "Testing."       , "Testing."   ,   nil   ] ,
    [ "."              , "."          ,   nil   ] ,
    [ "\t.0\n"         , "0.0"        ,   0.0   ] ,
    [ ".44"            , "0.44"       ,   0.44  ] ,
    [ "0"              , "0.0"        ,   0.0   ] ,
    [ " 0"             , "0.0"        ,   0.0   ] ,
    [ "0 "             , "0.0"        ,   0.0   ] ,
    [ "0 "             , "0.0"        ,   0.0   ] ,
    [ "0 "             , "0.0"        ,   0.0   ] ,
    [ " 0 "            , "0.0"        ,   0.0   ] ,
    [ " 0 "            , "0.0"        ,   0.0   ] ,
    [ " 0 "            , "0.0"        ,   0.0   ] ,
    [ "\t00\n "        , "0.0"        ,   0.0   ] ,
    [ " 1x "           , " 1x "       ,   nil   ] ,
    [ "1"              , "1.0"        ,   1.0   ] ,
    [ "1."             , "1."         ,   nil   ] ,
    [ "257"            , "257.0"      , 257.0   ] ,
    [ "1.3e1"          , "13.0"       ,  13.0   ] ,
    [ "1.3e2"          , "130.0"      , 130.0   ] ,
    [ "1a"             , "1a"         ,   nil   ]
  ].each do |orig_obj, expec_obj, expec_reply|
    meth_syntax = 'normalize_as_float!'
    method_testers << MutatorMethodTester.new(orig_obj, meth_syntax, expec_reply, expec_obj)
    end
  it_good_batch(method_testers, "normalize_as_float! returns correct String and updates receiver")

  # Rails (mostly) fixed the bugs in String#last and String#first
  # The only complaint now is passing a negative number returns a weird
  # result, as: "abc".first(-1) => "ab" ; "abc".last(-1) => "bc"
  # That's only a minor problem, so these two methods have been deprecated
  # from here.
  # # Test String#first and String#last :
  # first_testers = [] ; last_testers = []
  # [ [ ""     ,  3   , ""    , ""   ] ,
  #   [ ""     ,  2   , ""    , ""   ] ,
  #   [ ""     ,  nil , ""    , ""   ] ,
  #   [ ""     ,  1   , ""    , ""   ] ,
  #   [ ""     ,  0   , ""    , ""   ] ,
  #   [ ""     , -1   , ""    , ""   ] ,
  #
  #   [ "a"    ,  3   , "a"   , "a"  ] ,
  #   [ "a"    ,  2   , "a"   , "a"  ] ,
  #   [ "a"    ,  nil , "a"   , "a"  ] ,
  #   [ "a"    ,  1   , "a"   , "a"  ] ,
  #   [ "a"    ,  0   , ""    , ""   ] ,
  #   [ "a"    , -1   , ""    , ""   ] ,
  #
  #   [ "ab"   ,  3   , "ab"  , "ab" ] ,
  #   [ "ab"   ,  2   , "ab"  , "ab" ] ,
  #   [ "ab"   ,  nil , "a"   , "b"  ] ,
  #   [ "ab"   ,  1   , "a"   , "b"  ] ,
  #   [ "ab"   ,  0   , ""    , ""   ] ,
  #   [ "ab"   , -1   , ""    , ""   ] ,
  #
  #   [ "abc"  ,  4   , "abc" , "abc"] ,
  #   [ "abc"  ,  3   , "abc" , "abc"] ,
  #   [ "abc"  ,  2   , "ab"  , "bc" ] ,
  #   [ "abc"  ,  nil , "a"   , "c"  ] ,
  #   [ "abc"  ,  1   , "a"   , "c"  ] ,
  #   [ "abc"  ,  0   , ""    , ""   ] ,
  #   [ "abc"  , -1   , ""    , ""   ]
  # ].each do |orig_obj, arg, expec_first, expec_last|
  #   first_testers << IdempotentMethodTester.new(orig_obj, "first(#{arg})", expec_first)
  #   last_testers <<  IdempotentMethodTester.new(orig_obj, "last(#{arg})" , expec_last )
  #   end
  # it_good_batch(first_testers, "first() returns correct String without side effect")
  # it_good_batch(last_testers , "last() returns correct String without side effect")

  # Test String#random_text using its expected default pallette. If the default
  # pallette changes the results will be out-of-random, and will cause flunkage.
  tester = RandTextTester.new('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
  it 'String.random_text(0) returns ""' do
    s = String.random_text(0)
    s.should == ''
    end
  it "String.random_text returns a plausible 10-character string" do
    s = String.random_text # Default length should be 10.
    tester.should analyze_and_approve(s,10)
    end
  it "String.random_text(1) returns a plausible 1-char string" do
    s = String.random_text(1)
    tester.should analyze_and_approve(s,1)
    end
  it "String.random_text(100) returns a plausible 100-char string" do
    s = String.random_text(100)
    tester.should analyze_and_approve(s,100)
    end
  it "String.random_text(1000) returns a plausible 1000-char string" do
    s = String.random_text(1000)
    tester.should analyze_and_approve(s,1000)
    end
  it "Those String.random_text() returns should have shown no apparent pattern" do
    tester.should have_stats_within(32)
    end

  # Test String#random_text using a custom pallette.
  palet2 = '!@#$%^&*(){}[]+=/?\|-_"\';:abcxyzABCXYZ123890'
  tester2 = RandTextTester.new(palet2)
  it "String.random_text(1000,palet) returns a plausible string" do
    s = String.random_text(1000,palet2)
    tester2.should analyze_and_approve(s,1000)
    end
  it "That return should show no apparent pattern" do
    tester2.should have_stats_within(32)
    end

  # Test String#bardoc :
  it "understands bardoc modifiers to heredocs" do
    s = <<-eos.bardoc
      |This is a text of the emergent
      |bardoc system.
      |  with silver bells and cockle shells
      |  and pretty maids, all in a row.
      |
      |That is all.
      |
      eos
    s.should == "This is a text of the emergent\nbardoc system.\n  with silver bells and cockle shells\n  and pretty maids, all in a row.\n\nThat is all.\n"
    s = <<-end.bardoc
      end
    s.should == ""
    s = <<-x.bardoc
      |Yeah, yeah, yeah.
      x
    s.should == "Yeah, yeah, yeah."
    s1, s2, s3 = <<-end1.bardoc, <<-end2.bardoc, <<-end3.bardoc
        |The party of the first part
      end1
      end2
        |third
         third
        | third
        |
      end3
    s1.should == "The party of the first part"
    s2.should == ""
    s3.should == "third\n         third\n third\n"
    end

  # Test String.bardoc :
  it "understands String.bardoc constructs" do
    s = String.bardoc("
      |Dick said:
      |  See Spot run.
      |  Run, Spot, run.
      |
      |Sally said:
      |  See Dick run.
      ")
    s.should == "Dick said:\n  See Spot run.\n  Run, Spot, run.\n\nSally said:\n  See Dick run."
    s = String.bardoc("
      |  This one should have a
      |trailing newline character.
      |
      ")
    s.should == "  This one should have a\ntrailing newline character.\n"
    s = String.bardoc("|As should this one.
                       |")
    s.should == "As should this one.\n"
    s = String.bardoc("And it shouldn't get confused by ordinary strings.")
    s.should be_a_kind_of(String)
    s = String.bardoc("|These strings are \n|have undefined expectations,")
    s.should be_a_kind_of(String)
    s = String.bardoc("\n|except they should return a String object\n||")
    s.should be_a_kind_of(String)
    s = String.bardoc("without crashing\n|\n|")
    s.should be_a_kind_of(String)
    s = String.bardoc("")
    s.should be_a_kind_of(String)
    end

  end # describe
