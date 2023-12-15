-module(door).

-behaviour(gen_statem).

%%API
-export([start_link/1, start_monitor/1, enter/1, change_password/0, enter_new/1, finish_changing/0, stop/0, lock/0]).

%%Callbacks
-export([init/1, open/3, locked/3, callback_mode/0, suspended/3, terminate/3]).

-define(SERVER, ?MODULE).

-record(door_data, {
          code :: list(), 
  entered = [] :: string(),
  wrong_tries = 0 :: integer()
}).

%%API
-spec(start_link(Numbers :: string() | integer()) -> {ok, pid()}).
start_link(Numbers) when is_list(Numbers) ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, Numbers, []);
start_link(Numbers) ->
  gen_statem:start_link({local, ?SERVER}, ?MODULE, integer_to_list(Numbers), []).

-spec(start_monitor(Numbers :: string() | integer()) -> {ok, {pid(), reference()}}).
start_monitor(Numbers) when is_list(Numbers) ->
  gen_statem:start_monitor({local, ?SERVER}, ?MODULE, Numbers, []);
start_monitor(Numbers) ->
  gen_statem:start_monitor({local, ?SERVER}, ?MODULE, integer_to_list(Numbers), []).

-spec(enter(Numbers :: string() | integer()) -> {ok, next_numbers} | {error, Reason :: atom()}).
enter(Numbers) when is_list(Numbers) ->
  gen_statem:call(?SERVER, {enter, Numbers});
enter(Numbers) ->
  gen_statem:call(?SERVER, {enter, integer_to_list(Numbers)}).

-spec(change_password() -> {ok, next_numbers} | {error, Reason :: atom()}).
change_password() ->
  gen_statem:call(?SERVER, change).

-spec(enter_new(Numbers :: string() | integer()) -> {ok, next_numbers} | {error, Reason :: atom()}).
enter_new(Numbers) when is_list(Numbers) ->
  gen_statem:call(?SERVER, {enter_new, Numbers});
enter_new(Numbers) ->
  gen_statem:call(?SERVER, {enter_new, integer_to_list(Numbers)}).

-spec(finish_changing() -> {ok, password_changed} | {error, Reason :: atom()}).
finish_changing() ->
  gen_statem:call(?SERVER, finish_changing).

-spec(lock() -> {ok, locked} | {error, Reason :: atom()}).
lock() ->
  gen_statem:call(?SERVER, lock).

-spec(stop() -> ok).
stop() ->
  gen_statem:stop(?SERVER).

%%Callbacks
init(Numbers) ->
  process_flag(trap_exit, true),
  {ok, locked, #door_data{code = Numbers}}.

callback_mode() ->
  state_functions.

locked({call, From}, {enter, Numbers}, #door_data{entered = Entered, code = Code, wrong_tries = WrongTries} = DoorData) ->
  NewEnteredCode = string:join([Entered] ++ [Numbers], ""),
  case {WrongTries, check_code(NewEnteredCode, Code)} of
    {2, fail} ->
      {next_state, suspended, DoorData#door_data{wrong_tries = 0, entered = []}, [{reply, From, {error, suspended}}, {state_timeout, 10000, lock}]};
    {2, success} ->
      {next_state, open, DoorData#door_data{entered = [], wrong_tries = 0}, [{reply, From, {ok, opened}}, {state_timeout, 10000, lock}]};
    {_, in_process} ->
      {keep_state, DoorData#door_data{entered = NewEnteredCode}, [{reply, From, {ok, next_numbers}}]};
    {_, success} ->
      {next_state, open, DoorData#door_data{entered = [], wrong_tries = 0}, [{reply, From, {ok, opened}}, {state_timeout, 10000, lock}]};
    {_, fail} ->
      {keep_state, DoorData#door_data{entered = [], wrong_tries = WrongTries + 1}, [{reply, From, {error, wrong_code}}]}
  end;
locked({call, From}, change, _DoorData) ->
  io:format("You can't change password in locked state, open door first~n"),
  {keep_state_and_data, [{reply, From, {error, locked}}]};
locked({call, From}, {enter_new, _}, _DoorData) ->
  io:format("You can't change password in locked state, open door first~n"),
  {keep_state_and_data, [{reply, From, {error, locked}}]};
locked({call, From}, finish_changing, _DoorData) ->
  io:format("You can't change password in locked state, open door first~n"),
  {keep_state_and_data, [{reply, From, {error, locked}}]};
locked({call, From}, lock, _DoorData) ->
  {keep_state_and_data, [{reply, From, {error, already_locked}}]}.

open({call, From}, {enter, _Numbers}, _DoorData) ->
  {keep_state_and_data, [{reply, From, {error, already_open}}]};
open(state_timeout, lock, DoorData) ->
  io:format("Locked after timeout~n"),
  {next_state, locked, DoorData};
open({call, From}, change, DoorData) ->
  {keep_state, DoorData#door_data{code = []}, [{reply, From, {ok, enter_password}}, {state_timeout, infinity, lock}]};
open({call, From}, {enter_new, Numbers}, #door_data{entered = Entered, code = Code} = DoorData) when length(Code) == 0 ->
  NewEnteredCode = string:join([Entered] ++ [Numbers], ""),
  {keep_state, DoorData#door_data{entered = NewEnteredCode}, [{reply, From, {ok, next_numbers}}]};
open({call, From}, {enter_new, _Numbers}, #door_data{code = Code}) when length(Code) =/= 0 ->
  io:format("You must initiate changing process. Enter door:change_password() first.~n"),
  {keep_state_and_data, [{reply, From, {error, initiate_changing}}]};
open({call, From}, finish_changing, #door_data{entered = Entered} = DoorData) ->
  {keep_state, DoorData#door_data{code = Entered, entered = []}, [{reply, From, {ok, password_changed}}, {state_timeout, 10000, lock}]};
open({call, From}, lock, DoorData) ->
  {next_state, locked, DoorData, [{reply, From, {ok, locked}}]}.

suspended({call, From}, _, _DoorData) ->
  io:format("You are suspended~n"),
  {keep_state_and_data, [{reply, From, {error, suspended}}]};
suspended(state_timeout, lock, DoorData) ->
  io:format("You are free now~n"),
  {next_state, locked, DoorData}.

terminate(normal, _, _DoorData) ->
  io:format("Terminating~n"),
  ok.

check_code(NewEnteredCode, Code) when length(NewEnteredCode) < length(Code)->
  in_process;

check_code(NewEnteredCode, Code) when length(NewEnteredCode) > length(Code) ->
  fail;

check_code(NewEnteredCode, Code) when NewEnteredCode == Code ->
  success;

check_code(_NewEnteredCode, _Code) ->
  fail.
