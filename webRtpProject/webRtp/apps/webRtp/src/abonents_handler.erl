-module(abonents_handler).

-export([init/2, allowed_methods/2, content_types_provided/2, handle_get/2]).

init(Req, []) ->
  {cowboy_rest, Req, []}.

allowed_methods(Req, State) ->
  {[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
  {[{<<"application/json">>, handle_get}], Req, State}.

handle_get(Req0, State) ->
  case db_abonents:get_all_abonents() of
    {error, _} ->
      Req = cowboy_req:reply(404, Req0),
      {false, Req, State};
    Abonents ->
      Reply = jsone:encode(Abonents),
      Req = cowboy_req:reply(200, #{
                        <<"content-type">> => <<"application/json">>
                        }, Reply, Req0),
      {true, Req, State}
  end,
  todo.
