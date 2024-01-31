-module(abonent_handler).

-behaviour(cowboy_handler).

-export([
         init/2
        ]).

init(Req, State) ->
  io:format("Received ~p~n", [Req]),
  Method = cowboy_req:method(Req),
  Req2 = handle_request(Method, Req),
  {ok, Req2, State}.

handle_request(<<"GET">>, Req0) ->
  case cowboy_req:binding(abonent_num, Req0) of
        undefined ->
            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, jsone:encode(#{<<"result">> => <<"No number">>}), Req0);
        Num when is_binary(Num) ->
            Num2 = list_to_integer(binary_to_list(Num)),
            case db_abonents:get_abonent(Num2) of
                {error, _} ->
                    cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>}, jsone:encode(#{<<"result">> => <<"No such abonent">>}), Req0);
                {abonents, Num2, Name} ->
                    Reply = jsone:encode(#{<<"num">> => Num2, <<"Name">> => list_to_binary(Name)}),
                    cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Reply, Req0)
            end
    end;

handle_request(<<"POST">>, Req0) ->
  case cowboy_req:has_body(Req0) of
        true ->
            {ok, Body, _Req} = cowboy_req:read_body(Req0),
            Json = jsone:decode(Body),
            case length(Json) == 0 of
                true ->
                cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, jsone:encode(#{<<"result">> => <<"Empty body">>}), Req0);
                false ->
                    lists:foreach(fun(Abonent) ->
                                     Num = maps:get(<<"num">>, Abonent),
                                     Name =
                                         binary:bin_to_list(
                                             maps:get(<<"name">>, Abonent)),
                                     db_abonents:add_abonent(Num, Name) % todo: exception!
                                  end,
                                  Json),
                cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Body, Req0)
            end;
        false ->
                cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, jsone:encode(#{<<"result">> => <<"No body">>}), Req0)
    end;

handle_request(<<"DELETE">>, Req0) ->
  case cowboy_req:binding(abonent_num, Req0) of
        undefined ->
            cowboy_req:reply(400, #{<<"content-type">> => <<"application/json">>}, jsone:encode(#{<<"result">> => <<"No number">>}), Req0);
        Num when is_binary(Num) ->
            Num2 = list_to_integer(binary_to_list(Num)),
            case db_abonents:get_abonent(Num2) of
                {error, _} ->
                    cowboy_req:reply(404, #{<<"content-type">> => <<"application/json">>}, jsone:encode(#{<<"result">> => <<"No such abonent">>}), Req0);
                {abonents, Num2, Name} ->
                    Reply = jsone:encode(#{<<"num">> => Num2, <<"Name">> => list_to_binary(Name)}),
                    db_abonents:delete_abonent(Num2),
                    cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Reply, Req0)
            end
    end.
  
