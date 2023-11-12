%%%-------------------------------------------------------------------
%%% @author Ivan_Abramovich
%%% @copyright (C) 2023, <COMPANY>
%%% @doc
%%% Module stores and manages tuples like {Key, Value}.
%%% @end
%%% Created : 10. Nov 2023 13:49
%%%-------------------------------------------------------------------

-module(keylist).

-export([loop/1, init/1, start_monitor/1, start_link/1, add/4, is_member/2, take/2, find/2, delete/2, stop/1]).

-record(state,{
  list = [] :: [{Key :: any(), Value :: any()}],
  counter = 0 :: integer() 
}).

%% @doc Starting keylist with monitor.
-spec(start_monitor(Name :: atom()) -> {pid(), reference()}).
start_monitor(Name) ->
  {Pid, Ref} = spawn_monitor(?MODULE, init, [Name]),
  {Pid, Ref}.

%% @doc Starting keylist with link.
-spec(start_link(Name :: atom()) -> pid()).
start_link(Name) ->
  Pid = spawn_link(?MODULE, init, [Name]),
  Pid.

init(Name) ->
  register(Name, self()),
  loop(#state{}).

%% @doc Adding new tuple {Key, Value} to keylist with name - Name.
-spec(add(Name :: atom(), Key :: any(), Value :: any(), Comment :: string()) -> ok).
add(Name, Key, Value, Comment) ->
  Name ! {self(), Key, Value, Comment},
  ok.

%% @doc Checking if Key is member of keylist with name - Name.
-spec(is_member(Name :: atom(), Key :: any()) -> ok).
is_member(Name, Key) ->
  Name ! {self(), is_member, Key},
  ok.

%% @doc Sending tuple {Key, Value} and deleting this tuple from keylist.
-spec(take(Name :: atom(), Key :: any()) -> ok).
take(Name, Key) ->
  Name ! {self(), take, Key},
  ok.

%% @doc Sending tuple {Key, Value}.
-spec(find(Name :: atom(), Key :: any()) -> ok).
find(Name, Key) ->
  Name ! {self(), find, Key},
  ok.

%% @doc Deleting tuple {Key, Value} from keylist with name - Name.
-spec(delete(Name :: atom(), Key :: any()) -> ok).
delete(Name, Key) ->
  Name ! {self(), Key},
  ok.

%% @doc Stopping keylist.
-spec(stop(Name :: atom()) -> ok).
stop(Name) -> 
  Name ! stop,
  ok.

%%% @private
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
      loop(NewState);
    stop ->
      terminate()
  end.

%%% @private
terminate() ->
  exit(stopped).


