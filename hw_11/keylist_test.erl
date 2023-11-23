-module(keylist_test).

-include_lib("eunit/include/eunit.hrl").


keylist_test_() ->
  {
    setup,
    fun start/0,
    fun stop/1,
    [
      fun adding_test/0,
      fun is_member_test/0,
      fun find_test/0,
      fun delete_test/0,
      fun stop_test/0
    ]
  }.

start() ->
  {ok, {Pid, _Ref}} = keylist:start_monitor(keylist1),
  ?debugFmt("started~n", []),
  Pid.

stop(Pid) ->
  ?debugFmt("stopped", []),
  keylist:stop(Pid).


adding_test() ->
  ?_assertMatch({ok, _Counter}, keylist:add(keylist1, a, 3, "ab")).

is_member_test() ->
  ?_assertEqual({ok, true}, keylist:is_member(keylist1, a)).


find_test() ->
  ?_assertMatch({ok, _Item}, keylist:find(keylist1, a)).

delete_test() -> 
  ?_assertMatch({ok, _Counter}, keylist:delete(keylist1, a)).

stop_test() ->
  ?_assertEqual(ok, keylist:stop(keylist1)).
