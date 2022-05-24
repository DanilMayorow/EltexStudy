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
  {ok,[Number]}=io:fread("Number:","~d"),
  {ok,[Email]}=io:fread("Email:","~s"),
  maps:put(Number,[Name,Email],OldData).

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
    {Nbr, [Name, Email], I} ->
      io:format("Name:~s Number:~p Email:~s~n",[Name, Nbr, Email]),
      show_base(iter, I)
  end.

start() -> main(maps:new()).

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
