-module(converter).
-export([to_rub/1, to_rub2/1, to_rub3/1]).

-record(conv_info, {
  type,
  amount,
  commission
}).

to_rub({usd, Amount}) when is_integer(Amount), Amount > 0 ->
  io:format("Convert ~p to rub, amount ~p~n", [usd, Amount]),
  {ok, Amount * 75.5};
to_rub({euro, Amount}) when is_integer(Amount), Amount > 0 ->
  io:format("Convert ~p to rub, amount ~p~n", [euro, Amount]),
  {ok, Amount * 80};
to_rub({lari, Amount}) when is_integer(Amount), Amount > 0 ->
  io:format("Convert ~p to rub, amount ~p~n", [lari, Amount]),
  {ok, Amount * 29};
to_rub({peso, Amount}) when is_integer(Amount), Amount > 0 ->
  io:format("Convert ~p to rub, amount ~p~n", [peso, Amount]),
  {ok, Amount * 3};
to_rub({krone, Amount}) when is_integer(Amount), Amount > 0 ->
  io:format("Convert ~p to rub, amount ~p~n", [krone, Amount]),
  {ok, Amount * 10};

to_rub({yene, Amount}) when is_integer(Amount), Amount > 0 ->
  io:format("Convert ~p to rub, amount ~p~n", [yene, Amount]),
  {ok, Amount * 1.56};
to_rub({_, _Amount}) ->
  io:format("I don't know this currency(~n", []),
  {error, badarg}.


to_rub2({_Type, Amount} = Arg) ->
  Result =
  case Arg of
    {usd, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [euro, Amount]),
      {ok, Amount * 80};
    {euro, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [euro, Amount]),
      {ok, Amount * 80};
    {peso, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [peso, Amount]),
      {ok, Amount * 3};
    {krone, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [krone, Amount]),
      {ok, Amount * 10};
    {yene, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [yene, Amount]),
      {ok, Amount * 1.56};
    _Error->
      io:format("I don't know this currency(~n", []),
      {error, badarg}
  end,
  Result.

to_rub3(Arg) ->
  case Arg of
    {usd, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [euro, Amount]),
      {ok, Amount * 80};
    {euro, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [euro, Amount]),
      {ok, Amount * 80};
    {peso, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [peso, Amount]),
      {ok, Amount * 3};
    {krone, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [krone, Amount]),
      {ok, Amount * 10};
    {yene, Amount} when is_integer(Amount), Amount > 0 ->
      io:format("Convert ~p to rub, amount ~p~n", [yene, Amount]),
      {ok, Amount * 1.56};
    _Error ->
      io:format("I don't know this currency(~n", []),
      {error, badarg}
  end.

rec_to_rub(#conv_info{type = usd, amount = Amount, commission = Commission}) ->
  