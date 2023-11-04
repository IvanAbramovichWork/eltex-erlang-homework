-module(protocol).

-record(ipv4, {
  version,
  ihl,
  tos,
  total_len,
  id,
  flags,
  frag_offset,
  time_to_live,
  protocol,
  checksum,
  srs_addr,
  dest_addr,
  options_and_padding,
  data
}).

-export([ipv4/1, ipv4_listener/0]).

ipv4(<<Version:4, IHL:4, ToS:8, TotalLength:16,
  Identification:16, Flags:3, FragOffset:13,
  TimeToLive:8, Protocol:8, Checksum:16,
  SourceAddress:32, DestinationAddress:32,
  OptionsAndPadding:((IHL - 5) * 32)/bits,
  RemainingData/bytes>>
) when Version =:= 4 ->
  io:format("Received data ~p ~n", [RemainingData]),
  #ipv4{
    version = Version,
    ihl = IHL,
    tos = ToS,
    total_len = TotalLength,
    id = Identification,
    flags = Flags,
    frag_offset = FragOffset,
    time_to_live = TimeToLive,
    protocol = Protocol,
    checksum = Checksum,
    srs_addr = SourceAddress,
    dest_addr = DestinationAddress,
    options_and_padding = OptionsAndPadding,
    data = RemainingData
  };
ipv4(<<Version:4, _/bits>>
) when Version =/= 4 ->
  throw({wrong_version, {received_version, Version}});
ipv4(_) ->
  error(wrong_format).

ipv4_listener() ->
  receive
    {ipv4, From, BinData} when is_binary(BinData)->
      From ! ipv4(BinData);
    _ ->
      error(wrong_format)
  end.