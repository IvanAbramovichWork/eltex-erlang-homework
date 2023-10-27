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
