%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 31. май 2022 9:48
%%%-------------------------------------------------------------------
-module(recur).
-author("Dann Maj").

%% API
-export([pow/2, fact/1, to_n/1, a_to_b/2, aker/2, nsum/1, simple/1, ndiv/1, pal/1]).
-export([main/0, test/2]).

%Основная функция
main() ->
  TPW = test([pow,[1024, 1024]], 10),
  io:format("Pow-function: ~p (avg.:~p mc)~n",[TPW,lists:sum(TPW)/10]),
  TFQ = test([fact,[1024]], 10),
  io:format("Factorial: ~p (avg.:~p mc)~n",[TFQ,lists:sum(TFQ)/10]),
  TAK = test([aker,[4,1]], 10),
  io:format("Akkerman-function: ~p (avg.:~p mc)~n",[TAK,lists:sum(TAK)/10]),
  TDV = test([ndiv,[720720]], 10),
  io:format("Factorization: ~p (avg.:~p mc)~n",[TDV,lists:sum(TDV)/10]).


%Функция тестирования ([Функция, Аргументы], Кол-во запусков)
test([Fun, Arg],N) -> test([Fun, Arg],N, []).
test(_, 0, Acc) -> Acc;
test([Fun, Arg], N, Acc) -> {Time,_} = timer:tc(?MODULE,Fun,Arg), test([Fun, Arg], N-1, [Time|Acc]).


% Функция возведения в степень
pow(_X,0) -> 1;
pow(X,N) when N < 0 -> (1/X)*pow(X,N+1);
pow(X,N) -> X*pow(X,N-1).

% Фунция расчёта факториала
fact(X) -> fact(X, 1).
fact(0,Acc) -> Acc;
fact(X, Acc) -> fact(X-1, Acc*X).

% От 1 до n
to_n(N) -> to_n(N,1).
to_n(N,C) when C >= N ->
  io:format("~p~n",[C]);
to_n(N,C) ->
  io:format("~p ",[C]),
  to_n(N, C+1).

% От A до B
a_to_b(A,B) when A =:= B ->
  io:format("~p~n",[A]);
a_to_b(A,B) when A < B ->
  io:format("~p ",[A]),
  a_to_b(A+1,B);
a_to_b(A,B) ->
  io:format("~p ",[A]),
  a_to_b(A-1,B).

% Функция Аккермана
aker(M,N) when M < 0, N < 0 -> error;
aker(M,N) -> aker_c(M,N).
aker_c(0, N) -> N + 1;
%-------------------------  % Попытка оптимизации:
%aker_c(1, N) -> N + 2;     % Введение определения значения для (1, N) позволяет избавиться от развертывания (1, N->0)
%aker_c(2, N) -> 2*N + 3;   % Введение определения значения для (2, N) позволяет избавиться от развертывания (2, N->0)
%-------------------------  % Вывод: безуспешно, при (4,3) зависает на родолжительный срок
aker_c(M, 0) -> aker(M-1,1);
aker_c(M, N) when M > 0, N > 0 -> aker(M-1, aker(M, N-1)).

% Сумма цифр числа
nsum(N) ->
  case N div 10 of
    0 -> N;
    End -> (N rem 10) + nsum(End)
  end.

% Проверка числа на простоту
simple(N) -> simple(N, 2).
simple(N, _) when N < 2 -> false;
simple(N, D) when N rem D =:= 0 -> false;
simple(2, _) -> true;
simple(N, D) when D > (N rem 2) -> true;
simple(N, D) -> simple(N, D+1).

% Разложение на множители
ndiv(N) -> ndiv(N, 2).
ndiv(N, K) when K > N div 2 -> io:format("~p~n",[N]);
ndiv(N, K) ->
  case N rem K of
    0 -> io:format("~p ",[K]), ndiv(N div K, K);
    _ -> ndiv(N, K+1)
  end.

% Палиндром
pal(N) -> pal(integer_to_list(N),[]).
pal(L1, L2) when length(L1) == length(L2) ->  L1 == L2;
pal(L1, L2) when length(L1) < length(L2) ->  [_,S|T]=L2, L1 == [S|T];
pal([H|T], L2) -> pal(T, [H|L2]).