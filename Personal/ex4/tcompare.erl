%%%-------------------------------------------------------------------
%%% @author Mad Sam
%%% @copyright (C) 2022
%%% @doc
%%%
%%% @end
%%% Created : 25. май 2022 8:58
%%%-------------------------------------------------------------------
-module(tcompare).
-author("Dann Maj").

%% API
-export([main/0, main/2, fact_dir/1, fact_tail/1,
  fact_tail/2, sort_gen/1, sort_tail/1, test/2, test/3, partition/4]).

main() -> main([2000,2000],10).
main([Arg1,Arg2],NTests)->
  TFD = test([fact_dir,Arg1], NTests),
  TDT = test([fact_tail,Arg1], NTests),
  io:format("Now check time for factorials:~nDirect:~p (avg.:~p mc)~n",[TFD,lists:sum(TFD)/NTests]),
  io:format("Tail:~p (avg.:~p mc)~n",[TDT,lists:sum(TDT)/NTests]),
  List = [X||{_,X} <- lists:sort([ {rand:uniform(), N} || N <- lists:seq(0,Arg2)])],
  TSD = test([sort_gen,List],NTests),
  TST = test([sort_tail,List],NTests),
  io:format("Now check time for sorting func:~nDirect:~p (avg.:~p mc)~n",[TSD,lists:sum(TSD)/NTests]),
  io:format("Tail:~p (avg.:~p mc)~n",[TST,lists:sum(TST)/NTests]).

%Вычисление факториала через прямую рекурсию
fact_dir(X) when X =< 0 -> 1;
fact_dir(X) -> X*fact_dir(X-1).
%Вычисление факториала через хвостовую рекурсию
fact_tail(X) -> fact_tail(X,1).
fact_tail(0, Acc) -> Acc;
fact_tail(X, Acc) -> fact_tail(X-1, Acc*X).

test([Fun, Arg],N) -> test([Fun, Arg],N, []).
test(_, 0, Acc) -> Acc;
test([Fun, Arg], N, Acc) -> {Time,_} = timer:tc(?MODULE,Fun,[Arg]), test([Fun, Arg], N-1, [Time|Acc]).

%Быстрая сортировка через прямую рекурсию
sort_gen([]) -> [];
sort_gen([Pivot|Tail]) -> sort_gen([X || X <- Tail, X < Pivot]) ++ [Pivot] ++ sort_gen([X || X <- Tail, X >= Pivot]).

%Быстрая сортировка через хвостовую рекурсию
sort_tail([]) -> [];
sort_tail([Pivot | Rest]) ->
  {Smaller, Larger} = partition(Pivot, Rest, [], []),
  sort_tail(Smaller) ++ [Pivot] ++ sort_tail(Larger).

partition(_, [], Smaller, Larger) -> {Smaller, Larger};
partition(Pivot, [H | T], Smaller, Larger) ->
  if H =< Pivot ->
    partition(Pivot, T, [H | Smaller], Larger);
    H > Pivot -> partition(Pivot, T, Smaller, [H | Larger])
  end.
