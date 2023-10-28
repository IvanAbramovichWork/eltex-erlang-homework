-module(recursion).

-export([fac/1, tail_fac/1, duplicate/1, tail_duplicate/1]).


fac(N) when N == 0 -> 1;
fac(N) when N > 0 -> N * fac(N-1).

tail_fac(N) -> tail_fac(N, 1).
tail_fac(0, Acc) -> Acc;
tail_fac(N, Acc) when N > 0 -> tail_fac(N - 1, Acc * N).

duplicate([]) -> [];
duplicate([H|T]) -> [H, H | duplicate(T)].

tail_duplicate(List) -> tail_duplicate(List, []).
tail_duplicate([], Acc) -> Acc;
tail_duplicate([H|T], Acc) -> tail_duplicate(T, Acc ++ [H, H]).