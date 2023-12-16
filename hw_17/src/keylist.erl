-module(keylist).

-behaviour(gen_server).

-export([start_link/2, start_monitor/2, add/4, is_member/2, take/2, find/2, delete/2, stop/1, match/2, match_object/2, select/2]).

-export([init/1, handle_call/3, handle_info/2, terminate/2]).

-record(state,
{
  counter = 0 :: integer(),
  ets :: atom() | reference()
}).

-record(items, {
          key :: term(),
          value :: term(),
          comment :: string()
}).

-type start_mon_ret() :: {ok, {Pid :: pid(), MonRef :: reference()}} |
ignore | {error, Reason :: term()}.

-type start_ret() :: {ok, Pid :: pid()} | ignore | {error, Reason :: term()}.

-type atom_or_pid() :: pid() | LocalName :: atom().

-type item_in_keylist() :: {Key :: term(), Value :: term(), Comment :: string()}.

-spec(start_monitor(Name :: atom(), Tid :: atom() | reference()) -> start_mon_ret()).
start_monitor(Name, Tid) ->
  gen_server:start_monitor({local, Name}, ?MODULE, Tid, []).

-spec(start_link(Name :: atom(), Tid :: atom() | reference()) -> start_ret()).
start_link(Tid, Name) ->
  gen_server:start_link({local, Name}, ?MODULE, Tid, []).

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

-spec(match(NameOrPid :: atom_or_pid(), Pattern :: ets:match_pattern()) ->{ok, list()}).
match(NameOrPid, Pattern) ->
  gen_server:call(NameOrPid, {match, Pattern}).
-spec(match_object(NameOrPid :: atom_or_pid(), Pattern :: ets:match_pattern()) -> {ok, list()}).
match_object(NameOrPid, Pattern) ->
  gen_server:call(NameOrPid, {match_object, Pattern}).

-spec(select(NameOrPid :: atom_or_pid(), Filter :: function()) -> {ok, list()}).
select(NameOrPid, Filter) ->
  gen_server:call(NameOrPid, {select, Filter}).

-spec(stop(NameOrPid :: atom_or_pid()) -> ok).
stop(NameOrPid) ->
  gen_server:stop(NameOrPid).

init(Tid) ->
  process_flag(trap_exit, true),
  {ok, #state{ets = Tid}}.

handle_call({add, Key, Value, Comment}, _From, #state{counter = Counter, ets = Tid} = State) ->
  NewState = State#state{counter = Counter + 1},
  ets:insert(Tid, #items{key = Key, value = Value, comment = Comment}),
  {reply, {ok, NewState#state.counter}, NewState};
handle_call({is_member, Key}, _From, #state{ets = Tid , counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, ets:member(Tid, Key)}, NewState};
handle_call({take, Key}, _From, #state{ets = Tid , counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, ets:take(Tid, Key)}, NewState};
handle_call({find, Key}, _From, #state{ets = Tid , counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, ets:lookup(Tid, Key)}, NewState};
handle_call({delete, Key}, _From, #state{ets = Tid , counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  ets:delete(Tid, Key),
  {reply, {ok, State#state.counter}, NewState};
handle_call({match, Pattern}, _From, #state{ets = Tid, counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, ets:match(Tid, Pattern)}, NewState};
handle_call({match_object, Pattern}, _From, #state{ets = Tid, counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, ets:match_object(Tid, Pattern)}, NewState};
handle_call({select, Filter}, _From, #state{ets = Tid, counter = Counter} = State) ->
  NewState = State#state{counter = Counter + 1},
  {reply, {ok, ets:select(Tid, ets:fun2ms(Filter))}, NewState}.

handle_info({added_new_child, Pid, Name}, State) ->
  io:format("added_new_child with pid: ~p and name: ~p~n", [Pid, Name]),
  {noreply, State}.

terminate(_ , _State) ->
  io:format("terminating~n"),
  ok.

