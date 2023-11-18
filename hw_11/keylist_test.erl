-module(keylist_test).

-include_lib("eunit/include/eunit.hrl").


keylist_test_() ->
  {
    setup,
    fun start/0,
    fun stop/1,
    fun(SetupData) ->
      [
        is_registered_test(SetupData),
        adding_test(SetupData),
        is_member_test(SetupData),
        take_test(SetupData),
        find_test(SetupData),
        delete_test(SetupData),
        stop_test(SetupData)
      ]
    end
  }.

start() ->
  {ok, {Pid, _Ref}} = keylist:start_monitor(keylist1),
  ?debugFmt("started~n", []),
  Pid.

stop(Pid) ->
  ?debugFmt("stopped", []),
  keylist:stop(Pid).

is_registered_test(Pid) ->
  ?_assertEqual(Pid, whereis(keylist1)).

adding_test(Pid) ->
  ?_assertMatch({ok, _Counter}, keylist:add(Pid, a, 3, "ab")).

is_member_test(Pid) ->
  ?_assertEqual({ok, true}, keylist:is_member(Pid, a)).

take_test(Pid) ->
  keylist:add(Pid, a, 3, "ab"),
  ?_assertMatch({ok, _Item}, keylist:take(Pid, a)).

find_test(Pid) ->
  ?_assertMatch({ok, _Item}, keylist:find(Pid, a)).

delete_test(Pid) -> 
  ?_assertMatch({ok, _Counter}, keylist:delete(Pid, a)).

stop_test(_Pid) ->
  ?_assertEqual(ok, keylist:stop(keylist1)).
