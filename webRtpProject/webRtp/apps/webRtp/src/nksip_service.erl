-module(nksip_service).

-export([start_link/0, register_srv/0, call_abonent/1, call_abonent_async/1]).
-export([srv_init/2, srv_handle_cast/3, sip_bye/2]).

-include_lib("nksip/include/nksip.hrl").
-include_lib("nkserver/include/nkserver_module.hrl").

-spec start_link() -> {ok, pid()}.
start_link() ->
  nksip:start_link(nksip_service,
                   #{sip_listen => "sip:172.17.0.2:5060",
                     plugins => [nksip_uac_auto_auth],
                     sip_from => "sip:101@test.group"}).

-spec call_abonent(Num :: integer()) -> ok.
call_abonent(Num) ->
  gen_server:cast(nksip_service, {call, Num}).

-spec call_abonent_async(Num :: integer()) -> ok.
call_abonent_async(Num) ->
  gen_server:cast(nksip_service, {async_call, Num}).

srv_init(_Spec, State) ->
  case register_srv() of
    {ok, 200, _} ->
      io:format("registered~n");
    _ ->
      register_srv()
  end,
  {ok, State}.

srv_handle_cast({async_call, Num}, _Service, State) ->
  SDP =
    nksip_sdp:new("10.0.20.11", [{<<"audio">>, 9990, [{rtpmap, 0, "PCMU/8000"}, sendrecv]}]),
  CB =
    {callback,
     fun({resp, Code, Req, _Call}) ->
        case Code of
          200 ->
            {ok, Meta} = nksip_response:body(Req),
            {IpToConnect, PortToConnect} = parse_port_ip(Meta),
            io:format("Port: ~p~n", [PortToConnect]),
            send_rtp(IpToConnect, PortToConnect),
            {ok, DialogId} = nksip_dialog:get_handle(Req),
            nksip_uac:bye(DialogId, []);
          _ -> ok
        end
     end},
  {async, _ReqId} =
    nksip_uac:invite(nksip_service,
                     "sip:" ++ integer_to_list(Num) ++ "@10.0.20.11",
                     [{sip_pass, "1234"}, {body, SDP}, auto_2xx_ack, async, CB]),
  {noreply, State};
srv_handle_cast({call, Num}, _Service, State) ->
  SDP =
    nksip_sdp:new("10.0.20.11", [{<<"audio">>, 9990, [{rtpmap, 0, "PCMU/8000"}, sendrecv]}]),
  DlgId0 =
    case nksip_uac:invite(nksip_service,
                          "sip:" ++ integer_to_list(Num) ++ "@10.0.20.11",
                          [{sip_pass, "1234"}, {body, SDP}, auto_2xx_ack])
    of
      {ok, 403, _} ->
        register_srv(),
        {ok, 200, [{dialog, DlgId}]} =
          nksip_uac:invite(nksip_service,
                           "sip:" ++ integer_to_list(Num) ++ "@10.0.20.11",
                           [{sip_pass, "1234"}, {body, SDP}, auto_2xx_ack]),
        DlgId;
      {ok, 200, [{dialog, DlgId}]} ->
        DlgId
    end,
  {ok, Meta} = nksip_dialog:get_meta(invite_remote_sdp, DlgId0),
  {IpToConnect, PortToConnect} = parse_port_ip(Meta),
  send_rtp(IpToConnect, PortToConnect),
  nksip_uac:bye(DlgId0, []),
  {noreply, State}.

sip_bye(_Req, _Call) ->
  {reply, ok}.

register_srv() ->
  nksip_uac:register(nksip_service,
                     "sip:10.0.20.11:5060",
                     [{sip_pass, "1234"}, contact, {get_meta, [<<"contact">>]}]).

-spec parse_port_ip(#sdp{}) -> {Ip :: string(), Port :: integer()}.
parse_port_ip(Meta) ->
  [Head | _] = Meta#sdp.medias,
  {_, _, Ip} = Head#sdp_m.connect,
  Port = Head#sdp_m.port,
  {binary_to_list(Ip), Port}.

-spec send_rtp(Ip :: string(), Port :: integer()) -> ok.
send_rtp(Ip, Port) ->
  ConvertVoice =
    "ffmpeg -i priv/voice/generate.wav -codec:a pcm_mulaw -ar 8000 "
    "-ac 1 priv/voice/output.wav -y",
  StartVoice =
    "./voice_client priv/voice/output.wav " ++ Ip ++ " " ++ erlang:integer_to_list(Port),
  Cmd = ConvertVoice ++ " && " ++ StartVoice,
  os:cmd(Cmd),
  ok.
