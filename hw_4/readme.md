# 1

1> c(converter).\
{ok,converter}\
2> converter:to_rub2({usd, 100}).\
Convert euro to rub, amount 100\
{ok,8000}\
3> converter:to_rub2({peso, 12}).\
Convert peso to rub, amount 12\
{ok,36}\
4> converter:to_rub2({yene, 30}).\
Convert yene to rub, amount 30\
{ok,46.800000000000004}\
5> converter:to_rub2({euro, -15}).\
I don't know this currency(\
{error,badarg}\
6> converter:to_rub3({usd, 100}).\
Convert euro to rub, amount 100\
{ok,8000}\
7> converter:to_rub3({peso, 12}).\
Convert peso to rub, amount 12\
{ok,36}\
8> converter:to_rub3({yene, 30}).\
Convert yene to rub, amount 30\
{ok,46.800000000000004}\
9> converter:to_rub3({euro, -15}).\
I don't know this currency(\
{error,badarg}

# 2
6> rd(conv_info, {type, amount, commission}).\
conv_info\
20> c(converter).                                                                 
{ok,converter}\
21> converter:rec_to_rub(#conv_info{type = usd, amount = 100, commission = 0.01}).\
{ok,7920.0}\
22> converter:rec_to_rub(#conv_info{type = peso, amount = 12, commission = 0.02}).\
{ok,35.28}\
23> converter:rec_to_rub(#conv_info{type = yene, amount = 30, commission = 0.02}).\
{ok,45.864000000000004}\
24> converter:rec_to_rub(#conv_info{type = euro, amount = -15, commission = 0.02}).\
Wrong currency or amount\
{error,badarg}


29> c(converter).    
{ok,converter}\
30> converter: map_to_rub(#{type => usd, amount => 100, commission => 0.01}).\
{ok,7920.0}\
31> converter: map_to_rub(#{type => peso, amount => 12, commission => 0.02}).\
{ok,117.6}\
32> converter: map_to_rub(#{type => yene, amount => 30, commission => 0.02}).\
{ok,45.864000000000004}\
33> converter: map_to_rub(#{type => euro, amount => -15, commission => 0.02}).\
Wrong currency or amount\
{error,badarg}\


# 3.1

37> c(recursion).\
{ok,recursion}\
38> recursion:fac(5).\
120\
39> recursion:tail_fac(5).\
120\
40> recursion:tail_fac(0).\
1
# 3.2
60> recursion:duplicate([1, 2, 3, 4, 5, 6]).     
[1,1,2,2,3,3,4,4,5,5,6,6]\
61> recursion:duplicate([]).              
[]\
62> recursion:tail_duplicate([1, 2, 3, 4, 5, 6]).\
[1,1,2,2,3,3,4,4,5,5,6,6]\
63> recursion:tail_duplicate([]).                
[]

