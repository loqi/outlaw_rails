# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/spec_helper_meth_test"

describe Numeric do

  # Test Numeric#number_noun_phrase
  method_testers = []
  [ [99  , "number_noun_phrase(' balloon ', \"\t balloons\n \", 'red')" , "99 red balloons"         ],
    [2.0 , "number_noun_phrase('attorney general', 'attorneys general')", "2.0 attorneys general"   ],
    [2   , "number_noun_phrase('    ax    ', 'axes', '  fire ')"        , "2 fire axes"             ],
    [1.0 , "number_noun_phrase('regex', 'regexen', 'hairy')"            , "1.0 hairy regexen"       ],
    [1   , "number_noun_phrase('  alp  ', '  alps  ')"                  , "1 alp"                   ],
    [1   , "number_noun_phrase(' ox ', ' oxen ', ' wooley ')"           , "1 wooley ox"             ],
    [0   , "number_noun_phrase('sheep', 'sheeps')"                      , "0 sheeps"                ],
    [-1  , "number_noun_phrase('cane', 'canes', 'sweet, sticky')"       , "-1 sweet, sticky cane"   ],
    [-1.0, "number_noun_phrase('dude', 'dudes', 'bad')"                 , "-1.0 bad dudes"          ],
    [-2  , "number_noun_phrase('Dave', 'Daves', 'too many')"            , "-2 too many Daves"       ],
    [-2.0, "number_noun_phrase('direction', 'directions', 'general')"   , "-2.0 general directions" ],
    [-99 , "number_noun_phrase('a', 'b', 'c')"                          , "-99 c b"                 ]
  ].each do | num, meth_syntax, expec_reply |
    method_testers << IdempotentMethodTester.new(num, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "number_noun_phrase() returns correct String without side effect")

  # Test Numeric#cardinal_noun_phrase
  cardinals = %w{ No One Two Three Four Five Six Seven Eight Nine Ten Eleven
    Twelve Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen }
  method_testers = []
  # Plurals and singular, always represented verbally:
  cardinals.each_index do |num|
    meth_syntax = "cardinal_noun_phrase(\" \tthingie  \",\"\n thingies \",\"  big \n\n\")"
    expec_reply = "#{cardinals[num]} big #{ num==1 ? 'thingie' : 'thingies' }"
    method_testers << IdempotentMethodTester.new(num, meth_syntax, expec_reply)
    end
  # Singular, represented numerically:
  method_testers << IdempotentMethodTester.new(-1  , "cardinal_noun_phrase('thingy', 'thingies')", '-1 thingy'    )
  # Plurals, always represented numerically:
  method_testers << IdempotentMethodTester.new(21  , "cardinal_noun_phrase('thingy', 'thingies')", '21 thingies'  )
  method_testers << IdempotentMethodTester.new(20  , "cardinal_noun_phrase('thingy', 'thingies')", '20 thingies'  )
  method_testers << IdempotentMethodTester.new(1.0 , "cardinal_noun_phrase('thingy', 'thingies')", '1.0 thingies' )
  method_testers << IdempotentMethodTester.new(0.0 , "cardinal_noun_phrase('thingy', 'thingies')", '0.0 thingies' )
  method_testers << IdempotentMethodTester.new(-1.0, "cardinal_noun_phrase('thingy', 'thingies')", '-1.0 thingies')
  method_testers << IdempotentMethodTester.new(-100, "cardinal_noun_phrase('thingy', 'thingies')", '-100 thingies')
  # Run the tests:
  it_good_batch(method_testers, "cardinal_noun_phrase() returns correct String without side effect")

  end # describe
