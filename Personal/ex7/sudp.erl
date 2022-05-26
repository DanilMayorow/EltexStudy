%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 26. май 2022 14:16
%%%-------------------------------------------------------------------
-module(sudp).
-author("Dann Maj").

%% API
-export([start_server/0, listen/1]). %Функции сервера
-export([login/0, chat/2]). %Функции клиента


%%%-------------------------------------------------------------------
%%% РЕАЛИЗАЦИЯ СЕРВЕРА
%%%-------------------------------------------------------------------

start_server() ->
  {ok, Sock} = gen_udp:open(7740, [binary, {active, false}]),
  spawn(fun() -> listen(Sock) end), timer:sleep(infinity).

listen(Socket) ->
  case gen_udp:recv(Socket, 1, 10000) of
    {error, timeout} -> listen(Socket);
    {error, Reason} -> io:format("We have a truble: ~p",[Reason]);
    {ok, {Address, Port, Data}} ->
      case Data of
        <<"stop">> -> gen_udp:send(Socket, Address, Port, <<"Bye!">>), gen_udp:close(Socket), halt();
        Msg -> gen_udp:send(Socket, Address, Port, Msg), listen(Socket)
      end
  end.



%%%-------------------------------------------------------------------
%%% РЕАЛИЗАЦИЯ КЛИЕНТА
%%%-------------------------------------------------------------------

login() ->
  io:format("Hello, dear user! What is your name?~n"),
  {ok, Name} = io:fread("name> ","~s"),
  {ok, Socket} = gen_udp:open(0),
  chat(Name, Socket).

chat(Name, Socket) ->
 case string:trim(io:get_line(Name++"> ")) of
    Msg when Msg == "!quit"-> io:format("Good bye!~n");
    Msg when Msg == "!read"-> flush(), chat(Name, Socket);
    Msg -> gen_udp:send(Socket, {127,0,0,1}, 7740, list_to_binary(Msg)), chat(Name, Socket)
 end.

flush() ->
  receive
    M ->
      io:format("~p~n",[M]),
      flush()
  after 0 ->
    ok
  end.