%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 25. май 2022 11:25
%%%-------------------------------------------------------------------
-module(macro_nodes).
-author("Dann Maj").

%Не до конца полял задание №1 и просто переопределил вызов функции
-define(macro(Base, Power), math:pow(Base, Power)).
%% API
-export([main/0, listener/0, sender/0]).

main() ->
  io:format("Try our macro:~p~n",[?macro(4,10)]).

listener() ->
  receive
    {SNDR,Msg} -> io:format("They say: ~s~n",[Msg]), SNDR ! {self(), "I'm get your message, thanks!"}
  end.

sender() ->
  net_kernel:start(sndr,#{name_domain => shortnames}).
