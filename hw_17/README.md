1> keylist_mgr:start_child([keylist1]).\
{ok,<0.164.0>}\
2> keylist_mgr:start_child([keylist2]).\
{ok,<0.166.0>}\
3> keylist_mgr:get_names().\
{ok,[keylist1,keylist2]}\
4> keylist_mgr:stop_child(keylist1).\
terminating\
ok\
5>keylist_mgr:get_names().\
{ok,[keylist2]}\
6> keylist:add(keylist2, a, 23, "com").\
{ok,1}\
**Главный супервизор имеет стратегию one_for_one, чтобы падение одного из его детей, 
например keylist_mgr, не повлияло на работу остальных. Также keylist_sup (один из его
детей) имеет флаг significant, потому что работа keylist_mgr без keylist_sup не имеет 
смысла.**

**Для keylist_sup была выбрана стратегия simple_one_for_one исходя из задания. 
Так как он должен был создавать однообразные процессы динамически.**