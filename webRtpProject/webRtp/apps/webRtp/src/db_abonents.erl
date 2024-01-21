-module(db_abonents).

-record(abonents, {num, name}).

-export([start/0, 
         add_test_abonents/0, 
         get_abonent/1, 
         add_abonent/2, 
         get_all_abonents/0,
         delete_abonent/1
        ]).

start() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(abonents, [{attributes, record_info(fields, abonents)}]),
  ok.

add_test_abonents() ->
  mnesia:dirty_write(#abonents{num = 102, name = "Ivan Ivanov"}),
  mnesia:dirty_write(#abonents{num = 103, name = "Ivan Fedorov"}),
  mnesia:dirty_write(#abonents{num = 104, name = "Petr Petrov"}),
  mnesia:dirty_write(#abonents{num = 105, name = "Igor Igorev"}).

-spec get_abonent(Num :: integer()) ->
                   {abonents, integer(), string()} | {error, no_abonent}.
get_abonent(Num) ->
  F = fun() ->
         Abonent = mnesia:read({abonents, Num}),
         case Abonent =:= [] of
           true -> {error, no_abonent};
           false ->
             [Res] = Abonent,
             Res
         end
      end,
  mnesia:activity(transaction, F).

add_abonent(Num, Name) ->
  F = fun() ->
         case mnesia:read({abonents, Num}) =:= [] of
           true ->
             mnesia:write(#abonents{num = Num, name = Name}),
             ok;
           false -> {error, abonent_already_exist}
         end
      end,
  mnesia:activity(transaction, F).

get_all_abonents() ->
  F = fun() ->
         Abonents = mnesia:match_object(abonents, {abonents, '_', '_'}, read),
         case Abonents =:= [] of
           true -> {error, no_abonents};
           false ->
             lists:map(fun({abonents, Num, Name}) ->
                          maps:from_list([{<<"num">>, Num}, {<<"name">>, list_to_binary(Name)}])
                       end,
                       Abonents)
         end
      end,
  mnesia:activity(transaction, F).

delete_abonent(Num) ->
  F = fun() ->
         case get_abonent(Num) of
           {error, _} -> {error, no_abonent};
           {abonents, Num, _} -> mnesia:delete(abonents, Num, write)
         end
      end,
  mnesia:activity(transaction, F).
