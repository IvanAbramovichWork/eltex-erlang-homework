1> door:start_monitor(1234).\
{ok,{<0.88.0>,#Ref<0.3779089.1782841347.162796>}}\
2> door:enter(12).\
{ok,next_numbers}\
3> door:enter(34).\
{ok,opened}\
Locked after timeout\
4> door:enter(12345).\
Wrong tries: 1\
{error,wrong_code}\
5> door:enter(12345).\
Wrong tries: 2\
{error,wrong_code}\
6> door:enter(12345).\
You entered wrong password 3 times, you will be suspended on 10 seconds\
{error,suspended}\
You are free now\
7> door:change_password().\
You can't change password in locked state, open door first\
{error,locked}\
8> door:enter(1234).\
{ok,opened}\
9> door:change_password().\
{ok,enter_password}\
10> door:enter_new(123).\
{ok,next_numbers}\
11> door:enter_new(456).\
{ok,next_numbers}\
12> door:finish_changing().\
{ok,password_changed}\
Locked after timeout\
13> door:enter(123456).\
{ok,opened}
