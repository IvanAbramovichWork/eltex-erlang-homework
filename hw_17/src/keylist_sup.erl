-module(keylist_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

-define(SERVER, ?MODULE).

-record(items, {
          key :: term(),
          value :: term(),
          comment :: string()
}).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  Tid = ets:new(items, [named_table, {keypos, #items.key}, public]),
  SupFlags = #{strategy => simple_one_for_one},
  ChildSpecs =
    [#{id => keylist,
       start => {keylist, start_link, [Tid]},
       restart => permanent}],
  {ok, {SupFlags, ChildSpecs}}.
