-module(keylist).

-behaviour(gen_server).

-export([start_link/1, start_monitor/1, add/4, is_member/2, take/2, find/2, delete/2, stop/1]).

-export([init/1, handle_call/3, handle_info/2, terminate/2]).

-record(state,
{
  list = [] :: [{Key :: any(), Value :: any()}],
  counter = 0 :: integer()
}).

-type start_mon_ret() :: {ok, {Pid :: pid(), MonRef :: reference()}} |
ignore | {error, Reason :: term()}.

-type start_ret() :: {ok, Pid :: pid()} | ignore | {error, Reason :: term()}.

-type atom_or_pid() :: pid() | LocalName :: atom().

-type item_in_keylist() :: {Key :: term(), Value :: term(), Comment :: string()}.

-spec(start_monitor(Name :: atom()) -> start_mon_ret()).
start_monitor(Name) ->
  gen_server:start_monitor({local, Name}, ?MODULE, [], []).

-spec(start_link(Name :: atom()) -> start_ret()).
start_link(Name) ->
  gen_server:start_link({local, Name}, ?MODULE, [], []).

-spec(add(NameOrPid :: atom_or_pid(), Key :: term(), Value :: term(),
    Comment :: string()) -> {ok, Counter :: integer()}).
add(NameOrPid, Key, Value, Comment) ->
  gen_server:call(NameOrPid, {add, Key, Value, Comment}).

-spec(is_member(NameOrPid :: atom_or_pid(), Key :: term()) -> {ok, IsMember :: boolean()}).
is_member(NameOrPid, Key) ->
  gen_server:call(NameOrPid, {is_member, Key}).

-spec(take(NameOrPid :: atom_or_pid(), Key :: term()) -> {ok, Item :: item_in_keylist()}).
take(NameOrPid, Key) ->
  gen_server:call(NameOrPid, {take, Key}).

-spec(find(NameOrPid :: atom_or_pid(), Key :: term()) -> {ok, Item :: item_in_keylist()}).
find(NameOrPid, Key) ->
  gen_server:call(NameOrPid, {find, Key}).

-spec(delete(NameOrPid :: atom_or_pid(), Key :: term()) -> {ok, Counter :: integer()}).
delete(NameOrPid, Key) ->
  gen_server:call(NameOrPid, {delete, Key}).

-spec(stop(NameOrPid :: atom_or_pid()) -> ok).
stop(NameOrPid) ->
  gen_server:stop(NameOrPid).

init([]) ->
  {ok, #state{}}.

handle_call({add, Key, Value, Comment}, _From, #state{list = List, counter = Counter} = State) ->
  NewState = State#state{list = [{Key, Value, Comment} | List], counter = Counter + 1},
  {reply, {ok, NewState#state.counter}, NewState};
handle_call({is_member, Key}, _From, #state{list = List, counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, lists:keymember(Key, 1, List)}, NewState};
handle_call({take, Key}, _From, #state{list = List, counter = Counter} = State) ->
  NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
  {reply, {ok, lists:keyfind(Key, 1, List)}, NewState};
handle_call({find, Key}, _From, #state{list = List, counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, lists:keyfind(Key, 1, List)}, NewState};
handle_call({delete, Key}, _From, #state{list = List, counter = Counter} = State) ->
  NewState = State#state{list = lists:keydelete(Key, 1, List), counter = Counter + 1},
  {reply, {ok, State#state.counter}, NewState}.

handle_info({added_new_child, Pid, Name}, State) ->
  io:format("added_new_child with pid: ~p and name: ~p~n", [Pid, Name]),
  {noreply, State}.

terminate(normal, _State) ->
  io:format("terminating~n"),
  ok.

