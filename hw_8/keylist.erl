-module(keylist).

-export([loop/1, start_monitor/1, start_link/1]).

-record(state,{
  list = [],
  counter = 0
}).

loop(#state{list = List, counter = Counter} = State) ->
  receive
    {From, add, Key, Value, Comment} ->
      NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
      From ! {ok, NewState#state.counter},
      loop(NewState);
    {From, is_member, Key} ->
      NewState = State#state{counter = Counter + 1},
      From ! {lists:keymember(Key, 1, List), NewState#state.counter},
      loop(NewState);
    {From, take, Key} ->
      NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
      From ! {lists:keyfind(Key, 1, List), NewState#state.counter},
      loop(NewState);
    {From, find, Key} ->
      NewState = State#state{counter = Counter + 1},
      From ! {lists:keyfind(Key, 1, List), NewState#state.counter},
      loop(NewState);
    {From, delete, Key} ->
      NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
      From ! {ok, NewState#state.counter},
      loop(NewState)
  end.

start_monitor(Name) ->
  {Pid, Ref} = spawn_monitor(keylist, loop, [#state{}]),
  register(Name, Pid),
  {Pid, Ref}.

start_link(Name) ->
  Pid = spawn_link(keylist, loop, [#state{}]),
  register(Name, Pid),
  Pid.
