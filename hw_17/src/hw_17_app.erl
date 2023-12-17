-module(hw_17_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    hw_17_sup:start_link().

stop(_State) ->
    ok.