1> keylist_mgr:start_child(keylist1).\
keylist_mgr registred {keylist1, <0.164.0>} and monitoring it\
ok\
Childrens: [{keylist1,<0.164.0>}]\
2> keylist_mgr:start_child(keylist2).\
okkeylist_mgr registred {keylist2, <0.166.0>} and monitoring it\

Childrens: [{keylist2,<0.166.0>},{keylist1,<0.164.0>}]\
3> keylist_mgr:start_child(keylist3).\
keylist_mgr registred {keylist3, <0.168.0>} and monitoring it\
ok\
Childrens: [{keylist3,<0.168.0>},{keylist2,<0.166.0>},{keylist1,<0.164.0>}]\
4> keylist_mgr:stop_child(keylist1).\
<0.164.0> shutdown, keylist_mgr deleting his pid and name from childrens\
ok\
5> keylist_mgr:get_names().\
{ok,[keylist2,keylist3]}\
6> exit(whereis(keylist2), test).\
true\
<0.166.0> downed, keylist_mgr deleting his pid from childrens\
=SUPERVISOR REPORT==== 17-Dec-2023::15:54:48.852417 ===\
supervisor: {local,keylist_sup}\
errorContext: child_terminated\
reason: test\
offender: [{pid,<0.166.0>},\
{id,keylist},\
{mfargs,{keylist,start_link,[items,keylist2]}},\
{restart_type,transient},\
{significant,false},\
{shutdown,5000},\
{child_type,worker}]\

keylist_mgr registred {keylist2, <0.173.0>} and monitoring it\
Childrens: [{keylist2,<0.173.0>},{keylist3,<0.168.0>}]\
7> keylist:stop(keylist2).\
terminating\
<0.173.0> shutdown, keylist_mgr deleting his pid and name from childrens\
ok