# 2
2> self().\
<0.82.0>\
3> keylist:start_monitor(monitored).\
{<0.90.0>,#Ref<0.3756538077.1478230018.255817>}\
4> keylist:start_link(linked).\
<0.92.0>\
5> Linked = pid(0, 92, 0).\
<0.92.0>\
10> Linked ! {self(), add, "a", 23, "first"}.\
{<0.82.0>,add,"a",23,"first"}\
11> flush().\
Shell got {ok,1}\
ok\
13> Linked ! {self(), is_member, "a"}.\
{<0.82.0>,is_member,"a"}\
14> flush().\
Shell got {true,2}\
ok\
15> Linked ! {self(), take, "a"}.\
{<0.82.0>,take,"a"}\
16> flush().\
Shell got {{"a",23,"first"},3}\
ok\
17> Linked ! {self(), add, "a", 53, "second"}.\
{<0.82.0>,add,"a",53,"second"}\
18> flush().\
Shell got {ok,4}\
ok\
19> Linked ! {self(), find, "a"}.\
{<0.82.0>,find,"a"}\
20> flush().\
Shell got {{"a",53,"second"},5}\
ok\
21> Linked ! {self(), delete, "a"}.\
{<0.82.0>,delete,"a"}\
22> flush().\
Shell got {ok,6}\
ok\
23> self().\
<0.82.0>

# 3
23> self().\
<0.82.0>\
25> exit(pid(0, 90, 0), "end").\
true\
27> self().\
<0.82.0>\
28> flush().\
Shell got {'DOWN',#Ref<0.3756538077.1478230018.255817>,process,<0.90.0>,"end"}\
ok\
**Pid нашего процесса не изменился,
так как мы лишь мониторили данный процесс и не были
с ним связаны.\
По завершении данного процесса нам на почтовый ящик
пришла информация о самом процессе и причине его завершения.**

30> exit(Linked, "end").\
** exception exit: "end"\
31> flush().\
ok\
32> self().\
<0.122.0>\
**Pid нашего процесса изменился так как мы убили связанный
с нами процесс и erlang shell тоже упал и перезапустился.\
Наш почтовый ящик пуст, так как процесс erlang shell перезапустился.**

# 4 
32> self().\
<0.122.0>\
34> process_flag(trap_exit, true).\
true\
36> Linked = keylist:start_link(linked).\
<0.129.0>\
37> exit(Linked, "end").\
true\
38> flush().\
Shell got {'EXIT',<0.129.0>,"end"}\
ok\
39> self().\
<0.122.0>\
**Pid нашего процесса не изменился, т.к. выполнив команду
process_flag(trap_exit, true) наш процесс стал системным
и падение связанных с ним процессов не влияют на него.
При падении процессов, связанных с системным,
системный процесс будет получать от них информацию подобно монитору.**

# 5

2> process_flag(trap_exit, false).\
false\
3> keylist:start_link(linked1).\
<0.90.0>\
4> keylist:start_link(linked2).\
<0.92.0>\
5> self().\
<0.82.0>\
6> exit(pid(0, 90, 0), "end").\
** exception exit: "end"\
7> self().\
<0.95.0>\
8> is_process_alive(pid(0, 92, 0)).\
false\
**Прописав команду process_flag(trap_exit, false), наш процесс стал
несистемным процессом.
Таким образом, убив процесс linked1, наш связанный с ним процесс тоже умер,
что убило и связанный с нами процесс linked2.**

