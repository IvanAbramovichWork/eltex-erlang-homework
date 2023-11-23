# 3
1> self().\
<0.86.0>\
2> keylist_mgr:start().\
{ok,{<0.89.0>,#Ref<0.2164686821.805044228.138503>}}\
3> keylist_mgr:start_child(#{name => keylist3, restart => permanent}).\
{ok,<0.91.0>}\
4> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).\
added_new_child with pid: <0.93.0> and name: keylist2\
{ok,<0.93.0>}\
5> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).\
added_new_child with pid: <0.95.0> and name: keylist1\
added_new_child with pid: <0.95.0> and name: keylist1\
{ok,<0.95.0>}\
6> exit(whereis(keylist1), notnormal).\
<0.95.0> down with reason notnormal\
true\
keylist1 shall not down\
7> self().\
<0.86.0>\
8> whereis(keylist2).\
<0.93.0>\
9> whereis(keylist3).\
<0.91.0>\
**Процесс keylist1 упал и тут же запустился, т.к. он был перманентный. keylist_mgr не упал так
как на нем trap_exit = true. Eshell не упал, так как мониторит keylist_mgr. Остальные процессы тоже живы
так как с keylist_mgr все впорядке.**


15> keylist_mgr:start().\
{ok,{<0.115.0>,#Ref<0.2164686821.805044225.138173>}}\
16> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).\
{ok,<0.117.0>}\
17> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).\
added_new_child with pid: <0.119.0> and name: keylist2\
{ok,<0.119.0>}\
18> keylist:add(keylist1, a, 3, "ab").\
 exception exit: {timeout,{gen_server,call,[keylist1,{add,a,3,"ab"}]}}\
     in function  gen_server:call/2 (gen_server.erl, line 386)\
**Исключение вызвалось из-за тайм-аута (прошло 5 секунд). Это можно исправить, если в функции
gen_server:call/3 добавить большый тайм-аут в качестве аргумента или вообще вписать infinity**



3> keylist_mgr:start().\
{ok,{<0.98.0>,#Ref<0.1047089024.2419064833.182311>}}\
4> keylist_mgr:start_child(#{name => keylist1, restart => permanent}).\
{ok,<0.100.0>}\
5> keylist_mgr:start_child(#{name => keylist2, restart => permanent}).\
added_new_child with pid: <0.102.0> and name: keylist2\
{ok,<0.102.0>}\
7> self().\
<0.104.0>\
8> keylist:add(keylist1, a, 3, "ab").\
=ERROR REPORT==== 18-Nov-2023::16:37:50.775592 ===\
** Generic server keylist1 terminating \
** Last message in was {add,a,3,"ab"}\
** When Server state == {state,[],0}\
** Reason for termination ==\
** {badarith,[{keylist,handle_call,3,[{file,"keylist.erl"},{line,59}]},\
              {gen_server,try_handle_call,4,\
                          [{file,"gen_server.erl"},{line,1113}]},\
              {gen_server,handle_msg,6,[{file,"gen_server.erl"},{line,1142}]},\
              {proc_lib,init_p_do_apply,3,\
                        [{file,"proc_lib.erl"},{line,241}]}]}\
** Client <0.104.0> stacktrace\
** [{gen,do_call,4,[{file,"gen.erl"},{line,259}]},\
    {gen_server,call,2,[{file,"gen_server.erl"},{line,382}]},\
    {erl_eval,do_apply,7,[{file,"erl_eval.erl"},{line,750}]},\
    {shell,exprs,7,[{file,"shell.erl"},{line,782}]},\
    {shell,eval_exprs,7,[{file,"shell.erl"},{line,738}]},\
    {shell,eval_loop,4,[{file,"shell.erl"},{line,723}]}]

<0.100.0> down with reason {badarith,\
                               [{keylist,handle_call,3,\
                                    [{file,"keylist.erl"},{line,59}]},\
                                {gen_server,try_handle_call,4,\
                                    [{file,"gen_server.erl"},{line,1113}]},\
                                {gen_server,handle_msg,6,\
                                    [{file,"gen_server.erl"},{line,1142}]},\
                                {proc_lib,init_p_do_apply,3,\
                                    [{file,"proc_lib.erl"},{line,241}]}]}\
=CRASH REPORT==== 18-Nov-2023::16:37:50.775825 ===\
  crasher:\
    initial call: keylist:init/1\
    pid: <0.100.0>\
    registered_name: keylist1\
    exception error: an error occurred when evaluating an arithmetic expression\
      in function  keylist:handle_call/3 (keylist.erl, line 59)\
      in call from gen_server:try_handle_call/4 (gen_server.erl, line 1113)\
      in call from gen_server:handle_msg/6 (gen_server.erl, line 1142)\
    ancestors: [keylist_mgr,<0.86.0>,<0.85.0>,<0.71.0>,<0.66.0>,<0.70.0>,\
                  <0.65.0>,kernel_sup,<0.47.0>]\
    message_queue_len: 0\
    messages: []\
    links: [<0.98.0>]\
    dictionary: []\
    trap_exit: false\
    status: running\
    heap_size: 6772\
    stack_size: 28\
    reductions: 9504\
  neighbours:

** exception exit: {{badarith,[{keylist,handle_call,3,\
                                        [{file,"keylist.erl"},{line,59}]},\
                               {gen_server,try_handle_call,4,\
                                           [{file,"gen_server.erl"},{line,1113}]},\
                               {gen_server,handle_msg,6,\
                                           [{file,"gen_server.erl"},{line,1142}]},\
                               {proc_lib,init_p_do_apply,3,\
                                         [{file,"proc_lib.erl"},{line,241}]}]},\
                    {gen_server,call,[keylist1,{add,a,3,"ab"}]}}\
     in function  gen_server:call/2 (gen_server.erl, line 386)\
9> self().\
<0.107.0>\
10> whereis(keylist_mgr).\
<0.98.0>\
11> whereis(keylist1).\
undefined\
12> whereis(keylist2).\
<0.102.0>\
**keylist1 умирает, Eshell при вызове gen_server:call возвращается exception и он тоже умирает. Все остальные живут, так как Eshell не был связан с keylist_mgr, а просто мониторил его. Данное поведение можно исправить, если обернуть gen_server:call в try/catch.**
