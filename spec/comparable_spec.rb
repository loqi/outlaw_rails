# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/spec_helper_meth_test"

describe Comparable do

  # Test Comparable#not_below
  method_testers = []
  [ [99   , "not_below(100.0)" , 100.0 ],
    [99   , "not_below(99.0)"  , 99    ],
    [2.0  , "not_below(2)"     , 2.0   ],
    [2    , "not_below(2)"     , 2     ],
    [1    , "not_below(1.0)"   , 1     ],
    [0    , "not_below(1)"     , 1     ],
    [0    , "not_below(-1)"    , 0     ],
    [0.0  , "not_below(0)"     , 0.0   ],
    [-1.0 , "not_below(-2)"    , -1.0  ],
    [-1.0 , "not_below(-1)"    , -1.0  ],
    [-1   , "not_below(-1.0)"  , -1    ],
    [-2   , "not_below(2)"     , 2     ],
    [-99  , "not_below(-100)"  , -99   ],
    ['a'  , "not_below('b')"   , 'b'   ],
    ['b'  , "not_below('b')"   , 'b'   ],
    ['c'  , "not_below('b')"   , 'c'   ]
  ].each do | obj, meth_syntax, expec_reply |
    method_testers << IdempotentMethodTester.new(obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "not_below() returns correct reply without side effect")

  # Test Comparable#not_above
  method_testers = []
  [ [99   , "not_above(100.0)" , 99    ],
    [99   , "not_above(99.0)"  , 99    ],
    [2.0  , "not_above(2)"     , 2.0   ],
    [2    , "not_above(2)"     , 2     ],
    [1    , "not_above(1.0)"   , 1     ],
    [0    , "not_above(1)"     , 0     ],
    [0    , "not_above(-1)"    , -1    ],
    [0.0  , "not_above(0)"     , 0.0   ],
    [-1.0 , "not_above(-2)"    , -2    ],
    [-1.0 , "not_above(-1)"    , -1.0  ],
    [-1   , "not_above(-1.0)"  , -1    ],
    [-2   , "not_above(2)"     , -2    ],
    [-99  , "not_above(-100)"  , -100  ],
    ['a'  , "not_above('b')"   , 'a'   ],
    ['b'  , "not_above('b')"   , 'b'   ],
    ['c'  , "not_above('b')"   , 'b'   ]
  ].each do | obj, meth_syntax, expec_reply |
    method_testers << IdempotentMethodTester.new(obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "not_above() returns correct reply without side effect")

  # Test Comparable#not_outside
  method_testers = []
  [ [98   , "not_outside(99.0,100.0)" , 99.0  ],
    [99   , "not_outside(99.0,99.0)"  , 99    ],
    [2.0  , "not_outside(1,3)"        , 2.0   ],
    [2    , "not_outside(-50,1)"      , 1     ],
    [1    , "not_outside(1.0,1000)"   , 1     ],
    [0    , "not_outside(-5,5)"       , 0     ],
    [0    , "not_outside(5,-5)"       , 0     ],
    [0    , "not_outside(-10,-1)"     , -1    ],
    [0.0  , "not_outside(0,0)"        , 0.0   ],
    [-1.0 , "not_outside(-2,-3)"      , -2    ],
    [-1.0 , "not_outside(-1,-20)"     , -1.0  ],
    [-1   , "not_outside(100,200)"    , 100   ],
    [-2   , "not_outside(2,-1.0)"     , -1.0  ],
    ['a'  , "not_outside('b','e')"    , 'b'   ],
    ['b'  , "not_outside('e','b')"    , 'b'   ],
    ['c'  , "not_outside('b','e')"    , 'c'   ],
    ['d'  , "not_outside('e','b')"    , 'd'   ],
    ['e'  , "not_outside('b','e')"    , 'e'   ],
    ['f'  , "not_outside('e','b')"    , 'e'   ]
  ].each do | obj, meth_syntax, expec_reply |
    method_testers << IdempotentMethodTester.new(obj, meth_syntax, expec_reply)
    end
  it_good_batch(method_testers, "not_outside() returns correct reply without side effect")

  end # describe
