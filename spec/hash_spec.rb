# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/spec_helper_meth_test"

describe Hash do

  # Test Hash#slice() and Hash#slice!():
  plain_testers = [] ; mutator_testers = []
  [ [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , '[:a,:b,:c,:d,:e,:f,:g]' , {                                                       } , {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , ' :a,:b,:c,:d,:e,:f,:g ' , {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'} , {                                                                  } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , ' :c,:g,:a,:d,:e,:b,:f ' , {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'} , {                                                                  } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , ' :a,:b   ,:d,      :g ' , {:a=>'a',:b=>'b'        ,:d=>'d'                ,:g=>'g'} , {                :c=>'c'        ,:e=>'e',:f=>'f'                   } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , '       :c             ' , {                :c=>'c'                                } , {:a=>'a',:b=>'b'        ,:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , '                      ' , {                                                       } , {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , ' nil,nil,nil          ' , {                                                       } , {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , ' :b,:b, nil    ,:f,nil' , {        :b=>'b'                        ,:f=>'f'        } , {:a=>'a'        ,:c=>'c',:d=>'d',:e=>'e'        ,:g=>'g'           } ] ,
    [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g'           } , ':h,:g,:c,nil,:a,:g,nil' , {:a=>'a'        ,:c=>'c'                        ,:g=>'g'} , {        :b=>'b'        ,:d=>'d',:e=>'e',:f=>'f'                   } ] ,
    # [ {:a=>'a',:b=>'b',:c=>'c',:d=>'d',:e=>'e',:f=>'f',:g=>'g',nil=>false} , ':h,:g,:c,nil,:a,:g,nil' , {:a=>'a'        ,:c=>'c'        ,nil=>false     ,:g=>'g'} , {        :b=>'b'        ,:d=>'d',:e=>'e',:f=>'f'        ,nil=>false} ]
  ].each do |orig_obj, arg, expec_slice, expec_mutator_reply|
    plain_testers << IdempotentMethodTester.new(orig_obj, "slice(#{arg})" , expec_slice)
    mutator_testers <<  MutatorMethodTester.new(orig_obj, "slice!(#{arg})", expec_mutator_reply, expec_slice)
    end
  it_good_batch(plain_testers,   "slice returns correct Hash without side effect")
  it_good_batch(mutator_testers, "slice! returns correct Hash and updates receiver")

  # Test Hash#nils_to() and Hash#nils_to!():
  plain_testers = [] ; mutator_testers = []
  [ [ {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} , '""'                         , {:a=>'' ,:b=>'b',:c=>'' ,:d=>'d',:e=>'' ,:f=>'' ,:g=>'g'} ] ,
    [ {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} , '"",:z'                      , {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} ] ,
    [ {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} , '"",:a,:z'                   , {:a=>'' ,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} ] ,
    [ {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} , '"",:b'                      , {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} ] ,
    [ {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} , '"",:a,:b,:c'                , {:a=>'' ,:b=>'b',:c=>'' ,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} ] ,
    [ {:a=>nil,:b=>'b',:c=>nil,:d=>'d',:e=>nil,:f=>nil,:g=>'g'} , '"",:x,:c,:d,:y,:z,:e,:f,:g' , {:a=>nil,:b=>'b',:c=>'' ,:d=>'d',:e=>'' ,:f=>'' ,:g=>'g'} ] ,
    [ {        :b=>'b'        ,:d=>'d'                ,:g=>'g'} , '"",:x,:c,:d,:y,:z,:e,:f,:g' , {        :b=>'b'        ,:d=>'d'                ,:g=>'g'} ] ,
    [ {        :b=>'b'        ,:d=>'d'                ,:g=>'g'} , '""'                         , {        :b=>'b'        ,:d=>'d'                ,:g=>'g'} ]
  ].each do |orig_obj, arg, expec_reply|
    plain_testers << IdempotentMethodTester.new(orig_obj, "nils_to(#{arg})" , expec_reply             )
    mutator_testers <<  MutatorMethodTester.new(orig_obj, "nils_to!(#{arg})", expec_reply, expec_reply)
    end
  it_good_batch(plain_testers, "nils_to returns correct Hash without side effect")
  it_good_batch(mutator_testers, "nils_to! returns correct Hash and updates receiver")

  end # describe
