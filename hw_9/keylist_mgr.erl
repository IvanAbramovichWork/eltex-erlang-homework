%%%-------------------------------------------------------------------
%%% @author Ivan_Abramovich
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% Module manages kelists.
%%% @end
%%% Created : 10. Nov 2023 13:49
%%%-------------------------------------------------------------------

-module(keylist_mgr).

-export([start/0, init/0, start_child/1, stop_child/1, get_names/0, stop/0]).

-record(state, {
  childrens = [] :: {Name :: atom(), pid()}, 
  permanent = [] :: [pid()]
}).

%% @doc Starting keylist_mgr with monitor.
-spec(start() -> {pid(), reference()}).
start() ->
  spawn_monitor(keylist_mgr, init, []).

init() ->
  register(?MODULE, self()),
  process_flag(trap_exit, true),
  loop(#state{}).

%% @doc Starting child-keylist with Params, where name - name of keylist, 
%% permanent - type of keylist, if it's permanent it will be restarted after error or something.
-spec(start_child(Params :: #{name => atom(), restart => permanent | temporary}) -> ok).
start_child(Params) ->
  ?MODULE ! {self(), start_child, Params},
  ok.

%% @doc Stopping child-keylist (even if it's permanent).
-spec(stop_child(Name :: atom) -> ok). % Не стал добавлять Params вместо Name для удобства удаления
stop_child(Name) ->
  ?MODULE ! {self(), stop_child, Name},
  ok.

%% @doc Sending all names of child-keylists
-spec(get_names() -> ok).
get_names() ->
  ?MODULE ! {self(), get_names},
  ok.

%% @doc Stopping keylist_mgr, but before it stops, it sending stop messages to his childrens 
-spec(stop() -> ok).
stop() ->
  ?MODULE ! stop,
  ok.

%%% @private
loop(#state{childrens = Childrens, permanent = Permanent} = State) ->
  receive
    {From, start_child, Params} ->
      case whereis(maps:get(name, Params)) of
        Pid when is_pid(Pid) ->
          From ! {error, already_registred},
          loop(State);
        undefined ->
          Pid = keylist:start_link(maps:get(name, Params)),
          NewState = case maps:get(restart, Params) of
                       permanent ->
                         State#state{childrens = [{maps:get(name, Params), Pid} | Childrens], permanent = [Pid | Permanent]};
                       temporary ->
                         State#state{childrens = [{maps:get(name, Params), Pid} | Childrens]}
                     end,
          From ! {ok, Pid},
          loop(NewState)
      end;
    {From, stop_child, Name} -> 
      case whereis(Name) of
        Pid when is_pid(Pid) ->
          keylist:stop(Name),
          NewState = case lists:member(Pid, Permanent) of
                       true ->
                         State#state{childrens = lists:keydelete(Name, 1, Childrens), permanent = lists:delete(Pid, Permanent)};
                       false ->
                         State#state{childrens = lists:keydelete(Name, 1, Childrens)}
                     end,
          loop(NewState);
        undefined ->
          From ! {error, no_such_process},
          loop(State)

      end;
    {From, get_names} ->
      Names = proplists:get_keys(State#state.childrens),
      From ! Names,
      loop(State);
    {'EXIT', Pid, Reason} when Reason =/= stopped, Reason =/= killed ->
      io:format("~p down with reason ~p~n", [Pid, Reason]),
      NewState = case lists:member(Pid, Permanent) of
                   true ->
                     {Name, _Pid} = lists:keyfind(Pid, 2, Childrens),
                     NewChildrens = lists:keydelete(Pid, 2, Childrens),
                     NewPid = keylist:start_link(Name),
                     NewPermanent = lists:delete(Pid, Permanent),
                     io:format("~p shall not down~n", [Name]),
                     State#state{childrens = [{Name, NewPid} | NewChildrens], permanent = [NewPid | NewPermanent]};
                   false ->
                     State#state{childrens = lists:keydelete(Pid, 2, Childrens)}
                 end,
      loop(NewState);
    {'EXIT', Pid, Reason} ->
      io:format("~p down with reason ~p~n", [Pid, Reason]),
      NewState = case lists:member(Pid, Permanent) of
                   true ->
                     State#state{childrens = lists:keydelete(Pid, 2, Childrens), permanent = lists:delete(Pid, Permanent)};
                   false ->
                     State#state{childrens = lists:keydelete(Pid, 2, Childrens)}
                 end,
      loop(NewState);
    stop ->
      terminate(Childrens)
  end.

%%% @private
terminate(Childrens) ->
  lists:foreach(fun({Name, _Pid}) -> Name ! stop end, Childrens),
  exit(stop).
