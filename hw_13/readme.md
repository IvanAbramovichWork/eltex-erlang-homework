# 2 
4> keylist_mgr:start().\
{ok,{<0.100.0>,#Ref<0.1650549557.1531445250.68225>}}\
5> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).\
{ok,<0.102.0>}\
6> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).\
added_new_child with pid: <0.104.0> and name: keylist2\
{ok,<0.104.0>}\
7> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).\
added_new_child with pid: <0.106.0> and name: keylist3\
added_new_child with pid: <0.106.0> and name: keylist3\
{ok,<0.106.0>}\
8> keylist:add(keylist1, a, 3, "ab").\
{ok,1}\
9> keylist:add(keylist2, b, 4, "cde").\
{ok,1}\
10> keylist:add(keylist3, c, 5, "efgr").\
{ok,1}\
18> keylist:match(keylist1, {items, b, '$1', '$2'}).\
{ok,[[4,"cde"]]}\
19> keylist:match(keylist2, {items, c, '$1', '$2'}).\
{ok,[[5,"efgr"]]}


22> keylist:match_object(keylist1, {items, b, '_', '_'}).\
{ok,[{items,b,4,"cde"}]}\


24> rd(items, {key, value, comment}).\
items\
26> keylist:select(keylist1, fun(#items{key = Key, value = Value, comment = Comment}) when Value > 3 -> [Key, Value] end).\
{ok,[[c,5],[b,4]]}\

# 3

57> dets:open_file(items_dets, [{keypos, #items.key},{file, items_dets}]).\
{ok,items_dets}\
58> dets:insert(items_dets, #items{key = a, value = 3, comment = "ab"}).\
ok\
62> dets:lookup(items_dets, a).\
[#items{key = a,value = 3,comment = "ab"}]\
63> dets:close(items_dets).\
65> dets:open_file(items_dets, [{keypos, #items.key},{file, items_dets}]).\
{ok,items_dets}\
66> dets:lookup(items_dets, a).\
[#items{key = a,value = 3,comment = "ab"}]\
67> exit(kill).\
** exception exit: kill\
68> dets:open_file(items_dets, [{keypos, #items.key},{file, items_dets}]).\
{ok,items_dets}\
69> dets:lookup(items_dets, a).\
[#items{key = a,value = 3,comment = "ab"}]



