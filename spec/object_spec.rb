# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/spec_helper_meth_test"

describe Object do

  # Test Object#or_if_blank :
  method_testers = []
  [ [""                            , ""      , true    ] ,
    [""                            , nil     , true    ] ,
    [" "                           , "alt"   , true    ] ,
    [" "                           , nil     , true    ] ,
    [" a"                          , "0"     , false   ] ,
    ["a  "                         , "0"     , false   ] ,
    ["\t\n\r\n  a\n\t  \t\r a  \t" , " "     , false   ] ,
    ["\t\n\r\n   \n\t  \t\r    \t" , " "     , true    ] ,
    [[]                            , 'blank' , true    ] ,
    [[0]                           , 'blank' , false   ] ,
    [{}                            , 'blank' , true    ] ,
    [{0=>0}                        , 'blank' , false   ] ,
    [nil                           , 'blank' , true    ]
  ].each do |orig_obj, alt_obj, is_blank|
    meth_syntax = "or_if_blank(#{alt_obj.inspect})"
    expec_reply = is_blank ? alt_obj : orig_obj
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "or_if_blank() returns correct Object without side effect")

  # Test Object#blank_or_int? :
  method_testers = []
  [ [ nil              ,  true   ] ,
    [ ""               ,  true   ] ,
    [ "\t\n\r\n "      ,  true   ] ,
    [ "Testing."       ,  false  ] ,
    [ "."              ,  false  ] ,
    [ ".0"             ,  false  ] ,
    [ ".44"            ,  false  ] ,
    [ "0"              ,  true   ] ,
    [ " 0"             ,  true   ] ,
    [ "0 "             ,  true   ] , # Integer('0 ') throws in Ruby 1.8.6
    [ " 0 "            ,  true   ] ,
    [ "\t00\n "        ,  true   ] ,
  # [ "0."             ,  true   ] ,
  # [ "0.0"            ,  true   ] ,
  # [ "00."            ,  true   ] ,
  # [ "0.1"            ,  true   ] ,
  # [ "00.170"         ,  true   ] ,
  # [ "0.4"            ,  true   ] ,
  # [ "00.499"         ,  true   ] ,
  # [ "00.500"         ,  true   ] ,
  # [ "00.999"         ,  true   ] ,
  # [ "  000.000 "     ,  true   ] ,
  # [ " 0x "           ,  true   ] ,
    [ " 1x "           ,  true   ] ,
    [ "1"              ,  true   ] ,
    [ "1."             ,  true   ] ,
    [ "257"            ,  true   ] ,
    [ "1.3e1"          ,  true   ] ,
    [ "1.3e2"          ,  true   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "blank_or_int?"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "blank_or_int? correctly assesses without side effect")
  method_testers = []
  [ [ 10, nil              ,  true   ] ,
    [  3, nil              ,  true   ] ,
    [ 10, "0 "             ,  true   ] ,
    [  2, "0 "             ,  true   ] ,
    [ 10, " 0 "            ,  true   ] ,
    [  2, " 0 "            ,  true   ] ,
  # [ 10, "0."             ,  true   ] ,
  # [ 11, "0."             ,  true   ] ,
  # [  2, "31"             ,  false  ] ,
    [ 16, "1a"             ,  true   ] ,
    [ 16, "1f"             ,  true   ] ,
    [ 16, "1g"             ,  true   ] ,
    [ 11, "1a"             ,  true   ] ,
    [ 11, "1b"             ,  true   ] ,
    [ 10, "10"             ,  true   ] ,
    [ 10, "1a"             ,  true   ]
  ].each do |radix, orig_obj, expec_reply|
    meth_syntax = "blank_or_int?(#{radix.to_s})"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "blank_or_int?(radix) correctly assesses without side effect")

  # Test Object#nonblank_int? :
  method_testers = []
  [ [ nil              ,  false  ] ,
    [ ""               ,  false  ] ,
    [ "\t\n\r\n "      ,  false  ] ,
    [ "Testing."       ,  false  ] ,
    [ "."              ,  false  ] ,
    [ ".0"             ,  false  ] ,
    [ ".44"            ,  false  ] ,
    [ "0"              ,  true   ] ,
    [ " 0"             ,  true   ] ,
    [ "0 "             ,  true   ] , # Integer('0 ') throws in Ruby 1.8.6
    [ " 0 "            ,  true   ] ,
    [ "\t00\n "        ,  true   ] ,
    [ " 1x "           ,  true   ] ,
    [ "1"              ,  true   ] ,
    [ "1."             ,  true   ] ,
    [ "257"            ,  true   ] ,
    [ "1.3e1"          ,  true   ] ,
    [ "1.3e2"          ,  true   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "nonblank_int?"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "nonblank_int? correctly assesses without side effect")
  method_testers = []
  [ [ 10, nil              ,  false  ] ,
    [  3, nil              ,  false  ] ,
    [ 10, "0 "             ,  true   ] ,
    [  2, "0 "             ,  true   ] ,
    [ 10, " 0 "            ,  true   ] ,
    [  2, " 0 "            ,  true   ] ,
    [ 16, "1a"             ,  true   ] ,
    [ 16, "1f"             ,  true   ] ,
    [ 16, "1g"             ,  true   ] ,
    [ 11, "1a"             ,  true   ] ,
    [ 11, "1b"             ,  true   ] ,
    [ 10, "10"             ,  true   ] ,
    [ 10, "1a"             ,  true   ]
  ].each do |radix, orig_obj, expec_reply|
    meth_syntax = "nonblank_int?(#{radix.to_s})"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "nonblank_int?(radix) correctly assesses without side effect")

  # Test Object#to_i_or_nil :
  method_testers = []
  [ [ nil              ,   nil   ] ,
    [ ""               ,   nil   ] ,
    [ "Testing."       ,   nil   ] ,
    [ "."              ,   nil   ] ,
    [ "\t.0\n"         ,   nil   ] ,
    [ ".44"            ,   nil   ] ,
    [ "0"              ,     0   ] ,
    [ " 0"             ,     0   ] ,
    [ "0 "             ,     0   ] , # Integer('0 ') throws in Ruby 1.8.6
    [ " 0 "            ,     0   ] ,
    [ "\t00\n "        ,     0   ] ,
  # [ "0."             ,     0   ] ,
  # [ "0.0"            ,     0   ] ,
  # [ "00."            ,     0   ] ,
  # [ "0.1"            ,     0   ] ,
  # [ "00.170"         ,     0   ] ,
  # [ "0.4"            ,     0   ] ,
  # [ "00.499"         ,     0   ] ,
  # [ "00.500"         ,     0   ] ,
  # [ "00.999"         ,     0   ] ,
  # [ "  000.000 "     ,     0   ] ,
  # [ " 0x "           ,     0   ] ,
    [ " 1x "           ,     1   ] ,
    [ "1"              ,     1   ] ,
    [ "1."             ,     1   ] ,
    [ "257"            ,   257   ] ,
    [ "1.3e2"          ,     1   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "to_i_or_nil"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "to_i_or_nil without radix specified correctly translates without side effect")
  method_testers = []
  [ [ 10, nil              ,   nil   ] ,
    [  3, nil              ,   nil   ] ,
    [ 17, "\t\n\r\n "      ,   nil   ] ,
    [ 10, "0 "             ,     0   ] ,
    [  2, "0 "             ,     0   ] ,
    [ 10, " 0 "            ,     0   ] ,
    [  2, " 0 "            ,     0   ] ,
  # [ 10, "0."             ,     0   ] ,
  # [ 11, "0."             ,     0   ] ,
    [ 16, "1a"             ,    26   ] ,
    [ 16, "1f"             ,    31   ] ,
    [ 16, "1g"             ,     1   ] ,
    [ 11, "1a"             ,    21   ] ,
    [ 11, "1b"             ,     1   ] ,
    [ 10, "10"             ,    10   ] ,
    [ 10, "1a"             ,     1   ]
  ].each do |radix, orig_obj, expec_reply|
    meth_syntax = "to_i_or_nil(#{radix.to_s})"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "to_i_or_nil(radix) correctly translates without side effect")

  # Test Object#to_i_or_0 :
  method_testers = []
  [ [ nil              ,     0   ] ,
    [ ""               ,     0   ] ,
    [ "Testing."       ,     0   ] ,
    [ "."              ,     0   ] ,
    [ "\t.0\n"         ,     0   ] ,
    [ ".44"            ,     0   ] ,
    [ "0"              ,     0   ] ,
    [ " 0"             ,     0   ] ,
    [ "0 "             ,     0   ] , # Integer('0 ') throws in Ruby 1.8.6
    [ " 0 "            ,     0   ] ,
    [ "\t00\n "        ,     0   ] ,
  # [ "0."             ,     0   ] ,
  # [ "0.0"            ,     0   ] ,
  # [ "00."            ,     0   ] ,
  # [ "0.1"            ,     0   ] ,
  # [ "00.170"         ,     0   ] ,
  # [ "0.4"            ,     0   ] ,
  # [ "00.499"         ,     0   ] ,
  # [ "00.500"         ,     0   ] ,
  # [ "00.999"         ,     0   ] ,
  # [ "  000.000 "     ,     0   ] ,
  # [ " 0x "           ,     0   ] ,
    [ " 1x "           ,     1   ] ,
    [ "1"              ,     1   ] ,
    [ "1."             ,     1   ] ,
    [ "257"            ,   257   ] ,
    [ "1.3e2"          ,     1   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "to_i_or_0"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "to_i_or_0 without radix specified correctly translates without side effect")
  method_testers = []
  [ [ 10, nil              ,     0   ] ,
    [  3, nil              ,     0   ] ,
    [ 17, "\t\n\r\n "      ,     0   ] ,
    [ 10, "0 "             ,     0   ] ,
    [  2, "0 "             ,     0   ] ,
    [ 10, " 0 "            ,     0   ] ,
    [  2, " 0 "            ,     0   ] ,
  # [ 10, "0."             ,     0   ] ,
  # [ 11, "0."             ,     0   ] ,
    [ 16, "1a"             ,    26   ] ,
    [ 16, "1f"             ,    31   ] ,
    [ 16, "1g"             ,     1   ] ,
    [ 11, "1a"             ,    21   ] ,
    [ 11, "1b"             ,     1   ] ,
    [ 10, "10"             ,    10   ] ,
    [ 10, "1a"             ,     1   ]
  ].each do |radix, orig_obj, expec_reply|
    meth_syntax = "to_i_or_0(#{radix.to_s})"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "to_i_or_0(radix) correctly translates without side effect")

  # Test Object#blank_or_float? :
  method_testers = []
  [ [ nil              ,  true   ] ,
    [ ""               ,  true   ] ,
    [ "\t\n\r\n "      ,  true   ] ,
    [ "Testing."       , false   ] ,
    [ "."              , false   ] ,
    [ "\t.0\n"         ,  true   ] ,
    [ ".44"            ,  true   ] ,
    [ "0"              ,  true   ] ,
    [ " 0"             ,  true   ] ,
    [ "0 "             ,  true   ] ,
    [ "0 "             ,  true   ] ,
    [ "0 "             ,  true   ] ,
    [ " 0 "            ,  true   ] ,
    [ " 0 "            ,  true   ] ,
    [ " 0 "            ,  true   ] ,
    [ "\t00\n "        ,  true   ] ,
    [ " 1x "           , false   ] ,
    [ "1"              ,  true   ] ,
    [ "1."             , false   ] ,
    [ "257"            ,  true   ] ,
    [ "1.3e1"          ,  true   ] ,
    [ "1.3e2"          ,  true   ] ,
    [ "1a"             , false   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "blank_or_float?"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "blank_or_float? correctly assesses without side effect")

  # Test Object#nonblank_float? :
  method_testers = []
  [ [ nil              , false   ] ,
    [ ""               , false   ] ,
    [ "\t\n\r\n "      , false   ] ,
    [ "Testing."       , false   ] ,
    [ "."              , false   ] ,
    [ "\t.0\n"         ,  true   ] ,
    [ ".44"            ,  true   ] ,
    [ "0"              ,  true   ] ,
    [ " 0"             ,  true   ] ,
    [ "0 "             ,  true   ] ,
    [ "0 "             ,  true   ] ,
    [ "0 "             ,  true   ] ,
    [ " 0 "            ,  true   ] ,
    [ " 0 "            ,  true   ] ,
    [ " 0 "            ,  true   ] ,
    [ "\t00\n "        ,  true   ] ,
    [ " 1x "           , false   ] ,
    [ "1"              ,  true   ] ,
    [ "1."             , false   ] ,
    [ "257"            ,  true   ] ,
    [ "1.3e1"          ,  true   ] ,
    [ "1.3e2"          ,  true   ] ,
    [ "1a"             , false   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "nonblank_float?"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "nonblank_float? correctly assesses without side effect")

  # Test Object#to_f_or_nil :
  method_testers = []
  [ [ nil              ,   nil   ] ,
    [ ""               ,   nil   ] ,
    [ "\t\n\r\n "      ,   nil   ] ,
    [ "Testing."       ,   nil   ] ,
    [ "."              ,   nil   ] ,
    [ "\t.0\n"         ,   0.0   ] ,
    [ ".44"            ,   0.44  ] ,
    [ "0"              ,   0.0   ] ,
    [ " 0"             ,   0.0   ] ,
    [ "0 "             ,   0.0   ] ,
    [ "0 "             ,   0.0   ] ,
    [ "0 "             ,   0.0   ] ,
    [ " 0 "            ,   0.0   ] ,
    [ " 0 "            ,   0.0   ] ,
    [ " 0 "            ,   0.0   ] ,
    [ "\t00\n "        ,   0.0   ] ,
    [ " 1x "           ,   nil   ] ,
    [ "1"              ,   1.0   ] ,
    [ "1."             ,   nil   ] ,
    [ "257"            , 257.0   ] ,
    [ "1.3e1"          ,   1.3e1 ] ,
    [ "1.3e2"          ,   1.3e2 ] ,
    [ "1a"             ,   nil   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "to_f_or_nil"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "to_f_or_nil correctly translates without side effect")

  # Test Object#to_f_or_0 :
  method_testers = []
  [ [ nil              ,   0.0   ] ,
    [ ""               ,   0.0   ] ,
    [ "\t\n\r\n "      ,   0.0   ] ,
    [ "Testing."       ,   0.0   ] ,
    [ "."              ,   0.0   ] ,
    [ "\t.0\n"         ,   0.0   ] ,
    [ ".44"            ,   0.44  ] ,
    [ "0"              ,   0.0   ] ,
    [ " 0"             ,   0.0   ] ,
    [ "0 "             ,   0.0   ] ,
    [ "0 "             ,   0.0   ] ,
    [ "0 "             ,   0.0   ] ,
    [ " 0 "            ,   0.0   ] ,
    [ " 0 "            ,   0.0   ] ,
    [ " 0 "            ,   0.0   ] ,
    [ "\t00\n "        ,   0.0   ] ,
    [ " 1x "           ,   0.0   ] ,
    [ "1"              ,   1.0   ] ,
    [ "1."             ,   0.0   ] ,
    [ "257"            , 257.0   ] ,
    [ "1.3e1"          ,   1.3e1 ] ,
    [ "1.3e2"          ,   1.3e2 ] ,
    [ "1a"             ,   0.0   ]
  ].each do |orig_obj, expec_reply|
    meth_syntax = "to_f_or_0"
    method_testers << IdempotentMethodTester.new(orig_obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "to_f_or_0 correctly translates without side effect")

  end # describe
