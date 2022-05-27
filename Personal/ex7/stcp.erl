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
-export([start_server/0, start_server/2, accept/3]). %Функции сервера
-export([login/0, login/1, chat/3]). %Функции клиента


%%%-------------------------------------------------------------------
%%% РЕАЛИЗАЦИЯ СЕРВЕРА (DUO MODE)
%%%-------------------------------------------------------------------
start_server() -> start_server(5,1).
start_server(Active, Passive) ->
  if
    Active > 0 ->
        {ok, ListenActive} = gen_tcp:listen(7742, [binary, {active, true}]),
        [spawn(?MODULE, accept, [Id, ListenActive, active]) || Id <- lists:seq(1, Active)];
    true -> io:format("Open without active servers~n")
  end,
  if
    Passive > 0 ->
        {ok, ListenPassive} = gen_tcp:listen(7744, [binary, {active, false}]),
        [spawn(?MODULE, accept, [Id, ListenPassive,passive]) || Id <- lists:seq(Active+1, Active+Passive)];
    true -> io:format("Open without passive servers~n")
  end,
  if Active+Passive > 0 -> timer:sleep(infinity); true -> io:format("Waste of time~n") end,
  ok.

accept(Id, ListenSocket, Mode) ->
  case Mode of
    active ->
      io:format("Active socket #~p wait for client~n", [Id]),
      {ok, _Socket} = gen_tcp:accept(ListenSocket),
      io:format("Socket #~p(a), session started~n", [Id]),
      handle_connection(Id, ListenSocket, active);
    passive ->
      io:format("Passive socket #~p wait for client~n", [Id]),
      {ok, Socket} = gen_tcp:accept(ListenSocket),
      io:format("Socket #~p(p), session started~n", [Id]),
      handle_connection(Id, ListenSocket, passive, Socket)
  end.

handle_connection(Id, ListenSocket, active) ->
  receive
    {tcp, Socket, Msg} ->
      io:format("Socket #~p got message: ~p~n", [Id, Msg]),
      gen_tcp:send(Socket, Msg),
      handle_connection(Id, ListenSocket, active);
    {tcp_closed, _Socket} ->
      io:format("Socket #~p, session closed ~n", [Id]),
      accept(Id, ListenSocket, active)
  end.

handle_connection(Id, ListenSocket, passive, Socket) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, Msg} ->
      io:format("Socket #~p got message: ~p~n", [Id, Msg]),
      gen_tcp:send(Socket, Msg),
      handle_connection(Id, ListenSocket, passive, Socket);
    {error, _} ->
      io:format("Socket #~p, session closed ~n", [Id]),
      accept(Id, ListenSocket, passive)
  end.

%%%-------------------------------------------------------------------
%%% РЕАЛИЗАЦИЯ КЛИЕНТА
%%%-------------------------------------------------------------------
login() -> login(active).
login(Mode) ->
  io:format("Hello, dear user! What is your name?~n"),
  {ok, Name} = io:fread("name> ","~s"),
  case Mode of
    passive -> Port = 7744, Active = false;
    _ -> Port = 7742, Active = true
  end,
  case gen_tcp:connect({127,0,0,1}, Port, [binary, {packet, 0}, {active, Active}]) of
    {ok, Socket} -> chat(Name, Socket, Mode);
    {error, Reason} -> io:format("#Fail: ~p", [Reason])
  end.

chat(Name, Socket, active) ->
  case string:trim(io:get_line(Name++"> ")) of
    Msg when Msg == "!quit"-> io:format("Good bye!~n"), gen_tcp:close(Socket);
    Msg when Msg == "!read"-> flush(), chat(Name, Socket, active);
    Msg -> gen_tcp:send(Socket, list_to_binary(Msg)), chat(Name, Socket, active)
  end;

chat(Name, Socket, passive) ->
  case string:trim(io:get_line(Name++"> ")) of
    Msg when Msg == "!quit"-> io:format("Good bye!~n"), gen_tcp:close(Socket);
    Msg ->
      gen_tcp:send(Socket, list_to_binary(Msg)),
      chat(Name, Socket, passive)
  end.

flush() ->
  receive
    M ->
      io:format("~p~n",[M]),
      flush()
  after 0 ->
    ok
  end.
