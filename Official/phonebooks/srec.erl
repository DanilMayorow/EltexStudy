%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 01. июнь 2022 11:38
%%%-------------------------------------------------------------------
-module(srec).
-author("Dann Maj").
-record(person, {name ="", age, phone}).

%% API
-export([start/0, main/1]).

add_user(OldData) ->
  {ok,[Name]}=io:fread("Name:","~s"),
  {ok,[Number]}=io:fread("Number:","~d"),
  {ok,[Age]}=io:fread("Age:","~d"),
  [#person{name=Name, age=Age, phone=Number}|OldData].

del_user([], _) -> [];
del_user([#person{name=_Name, age=_Age, phone=Number} | T], Number) -> T;
del_user([H | T], Number) -> [H | del_user(T, Number)].

show_base([]) -> io:format("<end phonebook>~n");
show_base([#person{name=Name, age=Age, phone=Phone} | T]) ->
  io:format("Name: ~s Age: ~p Number: ~p ~n",[Name,Age,Phone]),
  show_base(T).

find_user(Base) ->
  {ok,[Number]}=io:fread("Number:","~d"),
  find_phone(Base, Number).

find_phone([#person{name=Name, age=Age, phone=Phone} | _], Phone) ->
  io:format("Name: ~s age: ~p for number: ~p ~n",[Name,Age,Phone]);
find_phone([_| T], Number) ->
  find_phone(T, Number);
find_phone([], _Number) ->
  io:format("<Number not found!>~n").

aveg_age(Base) -> io:format("Average age: ~f~n",[aveg_age(Base, {0,0})]).
aveg_age([], {SAge, CAge}) -> SAge/CAge;
aveg_age([#person{name=_Name, age=Age, phone=_Phone} | T], {SAge, CAge}) -> aveg_age(T, {SAge+Age, CAge+1}).

main(OldPB) ->
  {ok, [X]} = io:fread("Choose operation(add,show,find,age,del,bye): ", "~a"),
  NewB = case X of
           add -> add_user(OldPB);
           show -> show_base(OldPB), OldPB;
           find -> find_user(OldPB), OldPB;
           age -> aveg_age(OldPB), OldPB;
           del -> {ok,[Number]}=io:fread("Set user number: ","~d"),del_user(OldPB,Number);
           bye -> io:format("See you later!~n"), halt();
           (_) -> OldPB
         end,
  main(NewB).

start() ->
  case read_lines("phones.csv") of
    error -> main([]);
    File ->
      Out = string:split(File,"\n", all),
      io:fwrite("Data readed:~p~n",[Out]),
      Data = parse(Out),
      main(Data)
  end.

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
parse([H|T])-> [Name, Age, Phone]=string:split(H,";", all), [#person{name=Name, age=list_to_integer(Age), phone=list_to_integer(Phone)}| parse(T)].
