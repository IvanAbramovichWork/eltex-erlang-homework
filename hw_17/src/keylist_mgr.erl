-module(keylist_mgr).

-behaviour(gen_server).

-export([start_link/0, start_child/1, stop_child/1, get_names/0, stop/0]).
-export([init/1, terminate/2, handle_cast/2, handle_call/3]).

-define(KEYLIST_SUP, keylist_sup).

-record(state, {childrens = [] :: {Name :: atom(), pid()}}).

-spec start_link() -> gen_server:start_ret().
start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-spec start_child(Name :: [atom()]) -> {ok, pid()} | {error, atom()}.
start_child(Name) ->
  case supervisor:start_child(?KEYLIST_SUP, Name) of
    {ok, Child_pid} when is_pid(Child_pid) ->
      gen_server:call(?MODULE, {start_child, [Name], Child_pid});
    {error, Reason} ->
      {error, Reason}
  end.

-spec stop_child(Name :: atom()) -> ok | {error | atom()}.
stop_child(Name) ->
  case supervisor:terminate_child(?KEYLIST_SUP, whereis(Name)) of
    ok ->
      gen_server:cast(?MODULE, {stop_child, Name});
    {error, Error} ->
      {error, Error}
  end.

-spec get_names() -> {ok, [Name :: atom()]}.
get_names() ->
  gen_server:call(?MODULE, get_names).

-spec stop() -> ok.
stop() ->
  gen_server:stop(?MODULE).

init([]) ->
  process_flag(trap_exit, true),
  {ok, #state{}}.

handle_call(get_names, _From, #state{childrens = Childrens} = State) ->
  {reply, {ok, lists:flatten(proplists:get_keys(Childrens))}, State};
handle_call({start_child, Name, Pid}, _From, #state{childrens = Childrens} = State) ->
  NewState = State#state{childrens = [{lists:last(lists:flatten(Name)), Pid} | Childrens]},
  {reply, {ok, Pid}, NewState}.

handle_cast({stop_child, Name}, #state{childrens = Childrens} = State) ->
  NewState = State#state{childrens = proplists:delete(Name, Childrens)},
  {noreply, NewState}.

terminate(_ , _State) ->
  io:format("terminating~n"),
  ok.
