# 1
### 1.1
3> [X || X <- lists:seq(1, 10), X rem 3 == 0].\
[3,6,9]

### 1.2
6> List = [1, "hello", 100, boo, "boo", 9].\
[1,"hello",100,boo,"boo",9]\
7> [X * X || X<- List, is_integer(X)].\
[1,10000,81]

## 2
9> <<X:4, Y:2>> = <<42:6>>.\
<<42:6>>\
10> X.\
10\
11> Y.\
2\
**Паттерн матчинг между представлением числа 42 как 
6-битной последовательности справа и двумя переменными X (4 бита) и Y (2 бита)**

12> <<C:4,D:4>> = << 1998:6 >>.\
** exception error: no match of right hand side value <<14:6>>\
**Ошибка при матчинге: слева 8 бит, а справа 6**

13> <<C:4,D:2>> = << 1998:8 >>.\
** exception error: no match of right hand side value <<"Î">>\
**Ошибка при матчинге: слева 6 бит, а справа 8**

# 3
2> DataWrongVer = <<6:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello" >>.\
<<102,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104,101,108,108,111>>\
3> DataWrongFormat = <<4:4, 6:4, 0:8, 0:3>>.\
<<70,0,0:3>>\
4> Data1 = <<4:4, 6:4, 0:8, 232:16, 0:16, 0:3, 0:13, 0:8, 0:8, 0:16, 0:32, 0:32, 0:32, "hello" >>.\
<<70,0,0,232,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,104, 101,108,108,111>>\
5> Data2 = <<4:4, 6:4, 0:8, 232:16, 0:16, 0:3, 1:13, 0:8, 0:8, 0:16, 1:32, 0:32, 0:32, "world" >>.\
<<70,0,0,232,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,119, 111,114,108,100>>\
7> protocol:ipv4(DataWrongVer).                                                            
** exception throw: {wrong_version,{received_version,6}}\
in function  protocol:ipv4/1 (protocol.erl, line 48)\
**Возможно программист захочет обработать эту ошибку и учесть случай, когда придет ipv6, поэтому был использован throw**\
8> protocol:ipv4(DataWrongFormat).\
** exception error: wrong_format\
in function  protocol:ipv4/1 (protocol.erl, line 50)\
**Был использован error по той же логике, по которой erlang выдает error, когда мы вводим неправильное количество аргументов в функцию**\
9> protocol:ipv4(Data1).\
Received data <<"hello">>\
{ipv4,4,6,0,232,0,0,0,0,0,0,0,0,<<0,0,0,0>>,<<"hello">>}\
10> protocol:ipv4(Data2).                                                                    
Received data <<"world">>\
{ipv4,4,6,0,232,0,0,1,0,0,0,1,0,<<0,0,0,0>>,<<"world">>}

3> spawn(protocol, ipv4, [Data1]).\
<0.86.0>\
Received data <<"hello">>\
4> self().\
<0.82.0>\
5> spawn(protocol, ipv4, [DataWrongFormat]).\
=ERROR REPORT==== 4-Nov-2023::17:20:38.735584 ===\
Error in process <0.89.0> with exit value:\
{wrong_format,[{protocol,ipv4,1,[{file,"protocol.erl"},{line,50}]}]}\
<0.89.0>\
6> self().\                             
<0.82.0>\
**Pid не изменился так как процесс erlang shell никак не связан с процессом который спавнится**

# 4
13> ListenerPid = spawn(protocol, ipv4_listener, []).                                        
<0.118.0>\
14> ListenerPid ! {ipv4, self(), Data1}.\
16> flush().\
Shell got {ipv4,4,6,0,232,0,0,0,0,0,0,0,0,<<0,0,0,0>>,<<"hello">>}\
ok\
19> ListenerPid ! {ipv4, Data1}.\
21> is_process_alive(ListenerPid).\
false

