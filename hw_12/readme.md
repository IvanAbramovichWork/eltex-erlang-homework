# 2
2> string:tokens("a b c d e f j", " ").\
["a","b","c","d","e","f","j"]\
4> string:join(["a","b","c","d","e","f","j"], " ").\
"a b c d e f j"\
5> string:strip("    fkjskfj fjskfjd    ").\
"fkjskfj fjskfjd"\
9> string:strip("+++++fkjskfj fjskfjd++++++++", both, $+).\
"fkjskfj fjskfjd"\
10> string:to_upper("Foo").\
"FOO"\
13> string:to_lower("BAR").\
"bar"\
14> string:to_integer("5354534fkadf").\
{5354534,"fkadf"}\
15> list_to_integer("3443234").\
3443234\
16> byte_size(<<"fsdkfj fsdkfj  jfksfj jfslkf">>).\
28\
3> split_binary(<<"hello world foo bar">>, 6).\
{<<"hello ">>,<<"world foo bar">>}\
18> binary_part(<<"hello world foo bar">>, 6, 5).\
<<"world">>\
20> binary:split(<<"oh myyyyyy">>, [<<" ">>]).\
[<<"oh">>,<<"myyyyyy">>]\
21> binary:match(<<"foo foo foo">>, <<"foo">>).\
{0,3}\
22> binary:matches(<<"foo foo foo">>, <<"foo">>).\
[{0,3},{4,3},{8,3}]\
24> binary:replace(<<"foo foo foo">>, <<"f">>, <<"b">>, [global]).\
<<"boo boo boo">>\
25> binary_to_list(<<"how you doin">>).\
"how you doin"\
26> list_to_binary("whasaaa").\
<<"whasaaa">>\
27> Str = io_lib:format("Hello ~s", ["world"]).\
[72,101,108,108,111,32,"world"]\
28> lists:flatten(Str).\
"Hello world"

