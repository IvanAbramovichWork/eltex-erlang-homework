# 1
5> Fac = fun(X) -> recursion:tail_fac(X) end.
#Fun<erl_eval.42.3316493>\
7> Fac(5).\
120\
8> Dup = fun(X) -> recursion:tail_duplicate(X) end.\
#Fun<erl_eval.42.3316493>\
9> Dup([1, 2, 3]).\
[1,1,2,2,3,3]

# 2
### 2.1
10> Mult = fun(X, Y) -> X * Y end.\
#Fun<erl_eval.41.3316493>\
11> Mult(1, 5).\
5

### 2.2
41> ToRub= fun({usd, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 75.5};({euro, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 34};({peso, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 34}; ({krone, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 32}; ({yene, Amount}) when is_integer(Amount), Amount > 0 -> {ok, Amount * 1.56}; ({_, _Amount}) -> io:format("Wrong currency or amount~n", []), {error, badarg} end.\
#Fun<erl_eval.42.3316493>\
42> ToRub({usd, 100}).                                                                                                                                                                                                          
{ok,7550.0}                                                                                                                                                                                                                 
43> ToRub({peso, 12}).\
{ok,408}\
44> ToRub({yene, 30}).\
{ok,46.800000000000004}\
45> ToRub({euro, -15}).\
Wrong currency or amount\
{error,badarg}

# 3
52> Persons = [#person{id = 1, name = "Bob", age = 23, gender = male}, #person{id = 2, name = "Kate", age = 20, gender = female}, #person{id = 3, name = "Jack", age = 34, gender = male}, #person{id = 4, name = "Nata", age = 54,
gender = female}].\
[#person{id = 1,name = "Bob",age = 23,gender = male},\
#person{id = 2,name = "Kate",age = 20,gender = female},\
#person{id = 3,name = "Jack",age = 34,gender = male},\
#person{id = 4,name = "Nata",age = 54,gender = female}]

55> persons:filter(fun(#person{age = Age}) -> Age >= 30 end, Persons).\
[#person{id = 3,name = "Jack",age = 34,gender = male},\
#person{id = 4,name = "Nata",age = 54,gender = female}]

56> persons:filter(fun(#person{gender = Gender}) -> Gender == male end, Persons).\
[#person{id = 1,name = "Bob",age = 23,gender = male},\
#person{id = 3,name = "Jack",age = 34,gender = male}]

58> persons:any(fun(#person{gender = Gender}) -> Gender == female end, Persons).\
true

59> persons:all(fun(#person{age = Age}) -> Age >= 20 end, Persons).\
true

60> persons:all(fun(#person{age = Age}) -> Age =< 30 end, Persons).\
false

76> persons:update(fun(#person{name = "Jack", age = Age} = Person) -> Person#person{age = Age + 1}; (Person) -> Person end, Persons).\
[#person{id = 1,name = "Bob",age = 23,gender = male},\
#person{id = 2,name = "Kate",age = 20,gender = female},\
#person{id = 3,name = "Jack",age = 35,gender = male},\
#person{id = 4,name = "Nata",age = 54,gender = female}]

77> persons:update(fun(#person{age = Age, gender = female} = Person) -> Person#person{age = Age - 1}; (Person) -> Person end, Persons).\
[#person{id = 1,name = "Bob",age = 23,gender = male},\
#person{id = 2,name = "Kate",age = 19,gender = female},\
#person{id = 3,name = "Jack",age = 34,gender = male},\
#person{id = 4,name = "Nata",age = 53,gender = female}]

# 4
85> exceptions:catch_all(fun() -> 1/0 end).\
Action #Fun<erl_eval.43.3316493> failed, reason badarith\
error\
86> exceptions:catch_all(fun() -> throw(custom_exceptions) end).\
Action #Fun<erl_eval.43.3316493> failed, reason custom_exceptions\
throw\
87> exceptions:catch_all(fun() -> exit(killed) end).\
Action #Fun<erl_eval.43.3316493> failed, reason killed\
exit\
88> exceptions:catch_all(fun() -> erlang:error(runtime_exception) end).\
Action #Fun<erl_eval.43.3316493> failed, reason runtime_exception\
error
