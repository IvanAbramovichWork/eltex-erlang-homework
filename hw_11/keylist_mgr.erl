-module(keylist_mgr).

-behaviour(gen_server).

-export([start/0, start_child/1, stop_child/1, get_names/0, stop/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-record(state, {
  childrens = [] :: {Name :: atom(), pid()},
  permanent = [] :: [pid()]
}).

-type start_mon_ret() :: {ok, {Pid :: pid(), MonRef :: reference()}} |
ignore | {error, Reason :: term()}.

-spec(start() -> start_mon_ret()).
start() ->
  gen_server:start_monitor({local, ?MODULE}, ?MODULE, [], []).

-spec(start_child(Params :: #{name => atom(), restart => permanent | temporary}) -> start_mon_ret()).
start_child(Params) ->
  gen_server:call(?MODULE, {start_child, Params}).

-spec(stop_child(Name :: atom()) -> ok).
stop_child(Name) ->
  gen_server:cast(?MODULE, {stop_child, Name}).

-spec(get_names() -> {ok, [Name :: atom()]}).
get_names() ->
  gen_server:call(?MODULE, get_names).

-spec(stop() -> ok).
stop() ->
  gen_server:stop(?MODULE).

init([]) ->
  process_flag(trap_exit, true),
  {ok, #state{}}.

handle_call({start_child, #{name := Name, restart := Restart}}, _From, #state{childrens = Childrens, permanent = Permanent} = State) ->
  case whereis(Name) of
    undefined ->
      {ok, Pid} = keylist:start_link(Name),
      lists:foreach(fun({_ChildName, ChildPid}) -> ChildPid ! {added_new_child, Pid, Name} end, Childrens),
      NewState = case Restart of
                   permanent ->
                     State#state{childrens = [{Name, Pid} | Childrens], permanent = [Pid, Permanent]};
                   temporary ->
                     State#state{childrens = [{Name, Pid} | Childrens]}
                 end,
      {reply, {ok, Pid}, NewState};
    Pid when is_pid(Pid) ->
      {reply, {error, already_registred}, State}
  end;
handle_call(get_names, _From, #state{childrens = Childrens, permanent = _Permanent} = State) ->
  {reply, {ok, proplists:get_keys(Childrens)}, State}.

handle_cast({stop_child, Name}, #state{childrens = Childrens, permanent = Permanent} = State) ->
  case whereis(Name) of
    Pid when is_pid(Pid) ->
      keylist:stop(Name),
      NewState = case lists:member(Pid, Permanent) of
                   true ->
                     State#state{childrens = lists:keydelete(Name, 1, Childrens), permanent = lists:delete(Pid, Permanent)};
                   false ->
                     State#state{childrens = lists:keydelete(Name, 1, Childrens)}
                 end,
      {noreply, NewState};
    undefined ->
      {noreply, State}
  end;
handle_cast(stop, #state{childrens = _Childrens, permanent = _Permanent} = State) ->
  {noreply, State}.

handle_info({'EXIT', Pid, Reason}, #state{childrens = Childrens, permanent = Permanent} = State) when Reason =/= normal, Reason =/= killed ->
  io:format("~p down with reason ~p~n", [Pid, Reason]),
  NewState = handle_proc_down(Reason, Pid, Permanent, Childrens, State),
  {noreply, NewState};
handle_info({'EXIT', Pid, Reason}, #state{childrens = Childrens, permanent = Permanent} = State) ->
  io:format("~p down with reason ~p~n", [Pid, Reason]),
  NewState = handle_proc_down(Reason, Pid, Permanent, Childrens, State),
  {noreply, NewState};
handle_info({'DOWN', _Ref, process, Pid, Reason}, #state{childrens = Childrens, permanent = Permanent} = State) when Reason =/= normal, Reason =/= killed ->
  io:format("~p down with reason ~p~n", [Pid, Reason]),
  NewState = handle_proc_down(Reason, Pid, Permanent, Childrens, State),
  {noreply, NewState};
handle_info({'DOWN', _Ref, process, Pid, Reason}, #state{childrens = Childrens, permanent = Permanent} = State) ->
  io:format("~p down with reason ~p~n", [Pid, Reason]),
  NewState = handle_proc_down(Reason, Pid, Permanent, Childrens, State),
  {noreply, NewState}.

handle_proc_down(Reason, Pid, Permanent, Childrens, State) when Reason =/= normal, Reason =/= killed ->
  case lists:member(Pid, Permanent) of
    true ->
      {Name, _Pid} = lists:keyfind(Pid, 2, Childrens),
      NewChildrens = lists:keydelete(Pid, 2, Childrens),
      NewPid = keylist:start_link(Name),
      NewPermanent = lists:delete(Pid, Permanent),
      io:format("~p shall not down~n", [Name]),
      State#state{childrens = [{Name, NewPid} | NewChildrens], permanent = [NewPid | NewPermanent]};
    false ->
      State#state{childrens = lists:keydelete(Pid, 2, Childrens)}
  end;
handle_proc_down(_Reason, Pid, Permanent, Childrens, State) ->
  case lists:member(Pid, Permanent) of
    true ->
      State#state{childrens = lists:keydelete(Pid, 2, Childrens), permanent = lists:delete(Pid, Permanent)};
    false -> State#state{childrens = lists:keydelete(Pid, 2, Childrens)}
  end.


terminate(normal,  _State) ->
  io:format("terminating~n"),
  ok.



