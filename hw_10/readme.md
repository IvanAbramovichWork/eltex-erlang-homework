# 4
1> keylist_mgr:start().\
{ok,{<0.88.0>,#Ref<0.2826175017.1693450244.238186>}}\
2> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).\
{ok,<0.90.0>}\
3> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).\
added_new_child with pid: <0.92.0> and name: keylist2\
{ok,<0.92.0>}\
4> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).\
added_new_child with pid: <0.94.0> and name: keylist3\
added_new_child with pid: <0.94.0> and name: keylist3\
{ok,<0.94.0>}\
5> keylist_mgr:get_names().\
{ok,[keylist1,keylist2,keylist3]}\
6> keylist:add(keylist1, a, 3, "ab").\
{ok,1}\
7> keylist:is_member(keylist1, a).\
{ok,true}\
9> keylist:find(keylist1, a).\
{ok,{a,3,"ab"}}\
10> keylist:delete(keylist1, a).\
{ok,3}\
11> keylist:stop(keylist1).\
<0.90.0> down with reason shutdown\
ok\
12> keylist_mgr:stop_child(keylist2).\
<0.92.0> down with reason shutdown\
ok\
13> keylist_mgr:stop().\
ok\
14> whereis(keylist_mgr).\
undefined



