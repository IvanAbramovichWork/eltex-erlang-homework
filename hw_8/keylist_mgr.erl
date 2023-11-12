-module(keylist_mgr).

-export([start/0, init/0]).

-record(state, {
  childrens = []}).

start() ->
  spawn_monitor(keylist_mgr, init, []).

init() ->
  register(?MODULE, self()),
  process_flag(trap_exit, true),
  loop(#state{childrens = []}).

loop(#state{childrens = Childrens} = State) ->
  receive
    {From, start_child, Name} ->
      case whereis(Name) of
        Pid when is_pid(Pid) ->
          From ! {error, already_registred},
          loop(State);
        undefined -> 
          Pid = keylist:start_link(Name),
          NewState = State#state{childrens = [{Name, Pid} | Childrens]},
          From ! {ok, Pid},
          loop(NewState)
      end;
    {From, stop_child, Name} ->
      case whereis(Name) of
        Pid when is_pid(Pid) ->
          exit(Pid, killed),
          NewState = State#state{childrens = lists:keydelete(Name, 1, Childrens)},
          loop(NewState);
        undefined -> 
          From ! {error, no_such_process},
          loop(State)
      end;
    {From, get_names} ->
      Names = proplists:get_keys(State#state.childrens),
      From ! Names,
      loop(State);
    {'EXIT', Pid, Reason} ->
      io:format("~p down with reason ~p~n", [Pid, Reason]),
      NewState = State#state{childrens = lists:keydelete(Pid, 2, Childrens)},
      keylist_mgr ! {process_down, Pid, Reason},
      loop(NewState);
    stop ->
      terminate(Childrens)
  end.

terminate(Childrens) ->
  lists:foreach(fun({Name, _Pid}) -> Name ! stop end, Childrens),
  exit(stop).
