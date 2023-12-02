-module(door_tests).

-include_lib("eunit/include/eunit.hrl").

start_stop_test() ->
  ?assertMatch({ok, _}, door:start_link(1234)),
  ?assertEqual(ok, door:stop()),
  ?assertMatch({ok, _}, door:start_monitor(1234)),
  ?assertEqual(ok, door:stop()).

door_test_() ->
  {
   foreach, fun start/0, fun stop/1,
   [
    fun door_open_test/1,
    fun wrong_code_test/1,
    fun wrong_code_3_times/1,
    fun change_password_test/1
   ]
  }.



start() ->
  Code = 1234,
  door:start_link(Code),
  Code.

stop(_Code) ->
  door:stop().

door_open_test(_Code) ->
  [
   ?_assertMatch({ok, next_numbers}, door:enter(12)),
   ?_assertMatch({ok, opened}, door:enter(34))
  ].

wrong_code_test(_Code) ->
  [
   ?_assertMatch({error, _}, door:enter(12345))
  ].

wrong_code_3_times(_Code) ->
  door:enter(12345),
  door:enter(12345),
  [
   ?_assertMatch({error, suspended}, door:enter(12345))
  ].

change_password_test(_Code) ->
  door:enter(1234),
  [
   ?_assertMatch({ok, enter_password}, door:change_password()),
   ?_assertMatch({ok, next_numbers}, door:enter_new(12)),
   ?_assertMatch({ok, next_numbers}, door:enter_new(345)),
   ?_assertMatch({ok, password_changed}, door:finish_changing()),
   ?_assertMatch({ok, locked}, door:lock()),
   ?_assertMatch({ok, opened}, door:enter(12345))
  ].


