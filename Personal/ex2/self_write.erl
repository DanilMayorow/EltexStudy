%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(self_write).
-author("Dann Maj").

-record(user, {name="Ivan", city="Moscow", acc=0.0}).

%% API
-export([main/0, pow/2, fact/2, calc/2, test_cals/0, three_list/1, reverse/2, aker/2]).

main() -> io:format("Main").

%Задание 1. Самописные функции возведения в степень и расчёта факториала
pow(_X,0) -> 1;
pow(X,N) when N < 0 -> 1/(X*pow(X,N+1));
pow(X,N) -> X*pow(X,N-1).

fact(0,Acc) -> Acc;
fact(X, Acc) -> fact(X-1, Acc*X).

%Задание 2. Работа с записями-пользователями и расчёт их сбережений
calc([], Res) -> Res;
calc([#user{name=_Name, city=_City, acc=Acc}|T], Res) -> calc(T, Res+Acc);
calc(_,_) -> error.

test_cals() ->
  Us1 = #user{name="Dann", city="Novosibirsk", acc=81345.5},
  Us2 = #user{name="Bill", city="California", acc=1000000000.0},
  Us3 = #user{acc=15.62},
  Base = [Us1,Us2,Us3],
  io:format("All users have ~p dollars~n",[calc(Base,0)]).

%Задание 3. Меняем каждый третий элемент на -1
three_list([]) -> [];
three_list([One, Two, _Three|Rest]) -> [One, Two, -1] ++ three_list(Rest);
three_list([H|T]) -> [H|T];
three_list(_) -> error.

%Задание 4. Функция обращения списка
reverse([], _Acc) -> [];
reverse([H|T], Acc) -> reverse(T, [H|Acc]);
reverse(_, _) -> error.

%Задание 5. Функция Аккермана
aker(0,N) when N > 0 -> N + 1;
aker(M, 0) when M > 0 -> aker(M-1,1);
aker(M, N) when M > 0, N > 0 -> aker(M-1, aker(M, N-1));
aker(_,_) -> error.