-module(hw_17_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  SupFlags = #{strategy => one_for_one, auto_shutdown => any_significant},
  ChildSpecs =
    [#{id => keylist_mgr,
       start => {keylist_mgr, start_link, []},
       restart => transient,
       shutdown => brutal_kill,
       type => worker},
     #{id => keylist_sup,
       start => {keylist_sup, start_link, []},
       restart => transient,
       shutdown => brutal_kill,
       significant => true,
       type => supervisor}],
  {ok, {SupFlags, ChildSpecs}}.
