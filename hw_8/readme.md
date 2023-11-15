# 2
2> keylist_mgr:start().\
{<0.93.0>,#Ref<0.3766621960.641466370.2773>}\
3> keylist_mgr ! {self(), start_child, keylist1}.\
{<0.86.0>,start_child,keylist1}\
4> keylist_mgr ! {self(), start_child, keylist2}.\
{<0.86.0>,start_child,keylist2}\
5> keylist_mgr ! {self(), start_child, keylist3}.\
{<0.86.0>,start_child,keylist3}\
6> keylist3 ! {self(), add, "ab", 23, "first"}.\
{<0.86.0>,add,"ab",23,"first"}\
7> keylist3 ! {self(), is_member, "ab"}.\
{<0.86.0>,is_member,"ab"}\
8> keylist3 ! {self(), find, "ab"}.\
{<0.86.0>,find,"ab"}\
9> keylist3 ! {self(), take, "ab"}.\
{<0.86.0>,take,"ab"}\
10> flush().\
Shell got {ok,<0.96.0>} **создание keylist1**\
Shell got {ok,<0.97.0>} **создание keylist2**\
Shell got {ok,<0.99.0>} **создание keylist3**\
Shell got {ok,1} **создание keylist:add**\
Shell got {true,2} **создание keylist:is_member**\
Shell got {{"ab",23,"first"},3} **создание keylist:find**\
Shell got {{"ab",23,"first"},4} **создание keylist:take**\
ok

# 3
16> self().\
<0.107.0>\
17> exit(whereis(keylist1), kill).\
<0.96.0> down with reason killed **keylist_mgr залогировал падение процесса**\
true\
18> flush().\
ok\
19> self().\
<0.107.0>\
20> whereis(keylist2).\
<0.97.0>\
21> whereis(keylist3).\
<0.99.0>\
**Как только мы убиваем keylist1, keylist_mgr тут же логирует это и ему на почту приходит сообщение о процессе и причине. Однако на почту Eshell ничего не приходит, так как keylist_mgr не знает наш pid. Наш pid не изменяется, потому что мы не связаны с keylist1, мы лишь мониторим keylist_mgr.**

8> self().\
<0.86.0>\
9> exit(whereis(keylist_mgr), test).\
<0.86.0> down with reason test\
true\
10> flush().\
ok\
11> whereis(keylist_mgr).\
<0.93.0>\
12> self().\
<0.86.0>\
**Мы не можем, убить этот процесс (разве что с помощью kill) потому что на нем стоит флаг trap_exit = true. Поэтому ничего не происходит, почтовый ящик пуст, наш pid остался таким же. Однако keylist_mgr логирует падение нашего процесса, так как сообщение с exit матчится в receive**

12> self().\
<0.86.0>\
13> keylist_mgr ! stop.\
stop\
14> flush().\
Shell got {'DOWN',#Ref<0.2499931539.108003329.128204>,process,<0.93.0>,killed}\
ok\
15> whereis(keylist2).\
undefined\
16> whereis(keylist3).\
undefined\
17> self().\
<0.86.0>\
**Теперь же мы успешно убили keylist_mgr, так как stop вызвала функцию terminate, которая убила keylist_mgr. На наш почтовый ящик пришло сообщение о падении keylist_mgr, так как мы его мониторили, а наш pid соответственно не изменился. Процессы keylist2 и keylist3 тоже упали, так как были связаны с keylist_mgr.**



