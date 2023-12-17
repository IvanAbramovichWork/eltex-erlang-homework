-module(keylist_mgr).

-behaviour(gen_server).

-export([start_link/0, start_child/1, stop_child/1, get_names/0, stop/0]).
-export([init/1, terminate/2, handle_cast/2, handle_call/3, handle_info/2]).

-define(KEYLIST_SUP, keylist_sup).

-record(state, {childrens = [] :: {Name :: atom(), pid()}}).

-spec start_link() -> gen_server:start_ret().
start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-spec start_child(Name :: [atom()]) -> {ok, pid()} | {error, atom()}.
start_child(Name) ->
  gen_server:call(?MODULE, {start_child, Name}).

-spec stop_child(Name :: atom()) -> ok | {error | atom()}.
stop_child(Name) ->
  gen_server:cast(?MODULE, {stop_child, Name}).

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
  {reply, {ok, proplists:get_keys(Childrens)}, State};
handle_call({start_child, Name}, _From, #state{childrens = Childrens} = State) ->
  NewState = State#state{childrens = [{Name, undefined} | Childrens]},
  case supervisor:start_child(?KEYLIST_SUP, [Name]) of
    {ok, _} ->
      {reply, ok, NewState};
    {error, Reason} ->
      {reply, {error, Reason}, NewState}
  end.

handle_cast({stop_child, Name}, #state{childrens = Childrens} = State) ->
  NewState = State#state{childrens = proplists:delete(Name, Childrens)},
  supervisor:terminate_child(?KEYLIST_SUP, whereis(Name)),
  {noreply, NewState};
handle_cast({register, Name, Pid}, #state{childrens = Childrens} = State) ->
  monitor(process, Pid),
  NewState =
    case proplists:lookup(Name, Childrens) of
      {Child_name, _} ->
        State#state{childrens = [{Child_name, Pid} | proplists:delete(Child_name, Childrens)]};
      none ->
        State#state{childrens = [{Name, Pid} | Childrens]}
    end,
  io:format("keylist_mgr registred {~p, ~p} and monitoring it~n", [Name, Pid]),
  io:format("Childrens: ~p~n", [NewState#state.childrens]),
  {noreply, NewState}.

handle_info({'DOWN', _Ref, process, Pid, Reason},
            #state{childrens = Childrens} = State) when Reason == normal; Reason == shutdown ->
  io:format("~p shutdown, keylist_mgr deleting his pid and name from childrens~n", [Pid]),
  NewState =
    case lists:keyfind(Pid, 2, Childrens) of
      {ProcessName, _} ->
        State#state{childrens = proplists:delete(ProcessName, Childrens)};
      false ->
        State
    end,
  {noreply, NewState};
handle_info({'DOWN', _Ref, process, Pid, _Reason},
            #state{childrens = Childrens} = State) ->
  io:format("~p downed, keylist_mgr deleting his pid from childrens~n", [Pid]),
  NewState =
    case lists:keyfind(Pid, 2, Childrens) of
      {ProcessName, _} ->
        State#state{childrens =
                      [{ProcessName, undefined} | proplists:delete(ProcessName, Childrens)]};
      false ->
        State
    end,
  {noreply, NewState}.

terminate(_, _State) ->
  io:format("terminating~n"),
  ok.
