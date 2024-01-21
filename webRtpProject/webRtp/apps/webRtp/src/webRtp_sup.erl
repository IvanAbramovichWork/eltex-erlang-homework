%%%-------------------------------------------------------------------
%% @doc webRtp top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(webRtp_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    db_abonents:start(),
    db_abonents:add_test_abonents(),
    Dispatch = cowboy_router:compile([
        {'_', [{"/", hello_handler, []},
               {"/abonent/[:abonent_num]", abonent_handler, []},
               {"/abonents", abonents_handler, []}]}
    ]),
    HTTP = ranch:child_spec(
             cowboy_http, 100, ranch_tcp,
             [{port, 8080}],
             cowboy_clear,
             #{env=>#{dispatch=>Dispatch}}),
    Nksip1 = nksip:get_sup_spec(nksip_test_service, #{
            sip_from => "sip:101@test.group",
            plugins => [nksip_uac_auto_auth],
            sip_listen => "sip:172.17.0.2:5060"
        }),
    {ok, {{one_for_one, 10, 10}, [HTTP, Nksip1]}}.

%% internal functions
