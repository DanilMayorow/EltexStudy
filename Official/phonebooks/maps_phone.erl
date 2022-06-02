%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(maps_phone).
-author("Dann Maj").

%% API
-export([start/0, main/1, add_user/1, show_base/1, show_base/2, del_user/2]).

add_user(OldData) ->
  {ok,[Name]}=io:fread("Name:","~s"),
  {ok,[Age]}=io:fread("Age:","~d"),
  {ok,[Phone]}=io:fread("Phone:","~d"),
  maps:put(Phone,[Name,Age],OldData).

del_user(Number, OldData) ->
  Data = maps:remove(Number,OldData),
  case Data of
    {badmap, _} -> OldData;
    _ -> Data
  end.

show_base(Data) ->
  case maps:size(Data) of
    0 -> io:format("Phonebook is empty~n");
    _ ->
      Iter = maps:iterator(Data),
      show_base(iter, Iter)
  end.

show_base(iter, Iterator) ->
  case maps:next(Iterator) of
    none -> ok;
    {Nbr, [Name, Age], I} ->
      io:format("Name: ~s Age: ~p Number: ~p~n",[Name, Age, Nbr]),
      show_base(iter, I)
  end.

start() ->
  case read_lines("phones.csv") of
    error -> main(maps:new());
    File ->
      Out = string:split(File,"\n", all),
      io:fwrite("Data readed:~p~n",[Out]),
      FMap = maps:new(),
      Data = parse(Out, FMap),
      main(Data)
  end.

main(OldPB) ->
  {ok, [X]} = io:fread("Choose operation(add,show,del,bye): ", "~a"),
  NewB = case X of
           add -> add_user(OldPB);
           show -> show_base(OldPB), OldPB;
           del -> {ok,[Number]}=io:fread("Set user number: ","~d"),del_user(Number,OldPB);
           bye -> io:format("See you later!~n"), halt();
           (_) -> OldPB
         end,
  main(NewB).

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

parse([], Map) -> Map;
parse([H|T], FMap)-> [Name, Age, Phone]=string:split(H,";", all), parse(T, maps:put(list_to_integer(Phone),[Name,list_to_integer(Age)],FMap)).