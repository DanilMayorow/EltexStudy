%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 27. май 2022 15:10
%%%-------------------------------------------------------------------
-module(collect).
-author("Dann Maj").

%% API
-export([start/0, phonebook/1]).   %Основные функции
-export([add_user/2, del_user/2, show_book/1]).  %Работа с книгой контактов
-export([read_lines/1, get_all_lines/1, parse/1]).  %Работа с файлом

%%%-------------------------------------------------------------------
%%% ОСНОВНЫЕ ФУНКЦИИ
%%%-------------------------------------------------------------------
start() ->
  case read_lines("phones.csv") of
    error -> phonebook([]);
    File ->
      Out = string:split(File,"\n", all),
      io:fwrite("Data readed:~p~n",[Out]),
      Data = parse(Out),
      phonebook(Data)
  end.

phonebook(OldB) ->
  {ok, [X]} = io:fread("Choose operation(add,show,del): ", "~a"),
  NewB = case X of
           add -> {ok,[Name, Age, Phone]}=io:fread("Set date(Name Age Phone):","~s~d~d"), add_user([{Name, Age, Phone}],OldB);
           show -> show_book(OldB), OldB;
           del -> {ok,[User]}=io:fread("Set user Name: ","~s"),del_user(User,OldB);
           (_) -> io:format("Good bye!~n"), halt()
         end,
  phonebook(NewB).

%%%-------------------------------------------------------------------
%%% РАБОТА С КНИГОЙ КОНТАКТОВ
%%%-------------------------------------------------------------------
add_user(Data, Book) -> Book ++ Data.

del_user(_, []) -> [];
del_user(El,[{Name, _, _}|T]) when Name == El  -> T;
del_user(El, [H|T]) -> [H|del_user(El, T)].

show_book([]) -> ok;
show_book([{Name, Age, Number}|T]) -> io:format("Name:~s Info[age: ~p, number:~p] ~n",[Name, Age, Number]),  show_book(T).

%%%-------------------------------------------------------------------
%%% ЧТЕНИЕ ДАННЫХ ИЗ ФАЙЛА
%%%-------------------------------------------------------------------
read_lines(FileName) ->
  {Result, OUT} = file:open(FileName, [read]),
  if
    Result == ok -> io:format("File exported!~n"),
      try get_all_lines(OUT)
      after file:close(OUT)
      end;
    true -> io:format("File doesn't exported!~nResult:~p Info:~p~n",[Result, OUT]), error
  end.

get_all_lines(Device) ->
  case io:get_line(Device, "phones.csv") of
    eof  -> [];
    Line -> Line ++ get_all_lines(Device)
  end.

parse([]) -> [];
parse([H|T])-> [Name, Age, Number]=string:split(H,";", all), [{Name, Age, Number}| parse(T)].