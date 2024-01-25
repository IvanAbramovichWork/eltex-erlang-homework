-module(call_handler).

-behaviour(cowboy_handler).

-export([init/2]).

init(Req, State) ->
  Method = cowboy_req:method(Req),
  Req2 = handle_request(Method, Req),
  {ok, Req2, State}.

handle_request(<<"GET">>, Req0) ->
  case cowboy_req:binding(abonent_num, Req0) of
    undefined ->
      cowboy_req:reply(400,
                       #{<<"content-type">> => <<"application/json">>},
                       jsone:encode(#{<<"result">> => <<"No number">>}),
                       Req0);
    Num when is_binary(Num) ->
      Num2 = list_to_integer(binary_to_list(Num)),
      case db_abonents:get_abonent(Num2) of
        {error, _} ->
          cowboy_req:reply(404,
                           #{<<"content-type">> => <<"application/json">>},
                           jsone:encode(#{<<"result">> => <<"No such abonent">>}),
                           Req0);
        {abonents, _Num, _Name} ->
          nksip_service:call_abonent(Num2),
          cowboy_req:reply(200,
                           #{<<"content-type">> => <<"application/json">>},
                           jsone:encode(#{<<"result">> => <<"Calling">>}),
                           Req0)
      end
  end.
