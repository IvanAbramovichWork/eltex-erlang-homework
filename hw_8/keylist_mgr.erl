-module(keylist_mgr).

-export([start/0, init/0]).

-record(state, {
  childrens = []}).

start() ->
  {Pid, Ref} = spawn_monitor(keylist_mgr, init, []),
  {Pid, Ref}.

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
        _ -> % если заменить _ на undefind программа упадет с =ERROR REPORT= ... {{case_clause,undefined} при отправке сообщения start_child
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
        undefind -> % а здесь почему то нет никаких проблем с undefind ¯\_(ツ)_/¯
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
      terminate()
  end.

terminate() ->
  exit(killed).
