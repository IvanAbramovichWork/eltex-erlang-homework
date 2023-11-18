# 1

1> keylist_mgr:start().\
2> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).\
ok\
3> exit(whereis(keylist1), test).\
<0.92.0> down with reason test\
true\
keylist1 shall not down\
4> whereis(keylist1).\
<0.93.0>



