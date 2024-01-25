-module(broadcast_handler).

-behaviour(cowboy_handler).

-export([init/2]).

init(Req, State) ->
  io:format("Received ~p~n", [Req]),
  Method = cowboy_req:method(Req),
  Req2 = handle_request(Method, Req),
  {ok, Req2, State}.

handle_request(<<"GET">>, Req0) ->
  AbonentsNumbers =
    lists:map(fun(#{<<"num">> := Num}) -> Num end, db_abonents:get_all_abonents()),
  lists:foreach(fun(Num) -> nksip_service:call_abonent(Num) end, AbonentsNumbers),
  cowboy_req:reply(200,
                   #{<<"content-type">> => <<"application/json">>},
                   jsone:encode(#{<<"result">> => <<"Broadcasting">>}),
                   Req0).
