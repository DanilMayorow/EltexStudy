%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 26. май 2022 14:16
%%%-------------------------------------------------------------------
-module(stcp).
-author("Dann Maj").

%% API
-export([start_server/0, accept/2]). %Функции сервера
-export([login/0, chat/2]). %Функции клиента


%%%-------------------------------------------------------------------
%%% РЕАЛИЗАЦИЯ СЕРВЕРА
%%%-------------------------------------------------------------------
start_server() ->
  {ok, ListenSocket} = gen_tcp:listen(7742, [binary, {active, true}]),
  [spawn(?MODULE, accept, [Id, ListenSocket]) || Id <- lists:seq(1, 5)],
  timer:sleep(infinity),
  ok.

accept(Id, ListenSocket) ->
  io:format("Socket #~p wait for client~n", [Id]),
  {ok, _Socket} = gen_tcp:accept(ListenSocket),
  io:format("Socket #~p, session started~n", [Id]),
  handle_connection(Id, ListenSocket).

handle_connection(Id, ListenSocket) ->
  receive
    {tcp, Socket, Msg} ->
      io:format("Socket #~p got message: ~p~n", [Id, Msg]),
      gen_tcp:send(Socket, Msg),
      handle_connection(Id, ListenSocket);
    {tcp_closed, _Socket} ->
      io:format("Socket #~p, session closed ~n", [Id]),
      accept(Id, ListenSocket)
  end.

%%%-------------------------------------------------------------------
%%% РЕАЛИЗАЦИЯ КЛИЕНТА
%%%-------------------------------------------------------------------

login() ->
  io:format("Hello, dear user! What is your name?~n"),
  {ok, Name} = io:fread("name> ","~s"),
  {ok, Socket} = gen_tcp:connect({127,0,0,1}, 7742, [binary, {packet, 0}, {active, true}]),
  chat(Name, Socket).

chat(Name, Socket) ->
  case string:trim(io:get_line(Name++"> ")) of
    Msg when Msg == "!quit"-> io:format("Good bye!~n"), gen_tcp:close(Socket);
    Msg when Msg == "!read"-> flush(), chat(Name, Socket);
    Msg -> gen_tcp:send(Socket, list_to_binary(Msg)), chat(Name, Socket)
  end.

flush() ->
  receive
    M ->
      io:format("~p~n",[M]),
      flush()
  after 0 ->
    ok
  end.
