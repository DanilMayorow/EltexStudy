%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 27. май 2022 8:35
%%%-------------------------------------------------------------------
-module(sfsm).
-behaviour(gen_statem).
-author("Dann Maj").

%% API
-export([main/0, readf/1]). % Функции работы через узлы
-export([wait/3, open/3, read/3, send/3]). %Состояния КА
-export([terminate/3, code_change/4, init/1, callback_mode/0]). %Обязательные функции обратного вызова
-export([start/0, recv/0, get_data/0, find/0, answer/0, stop/0]). %Функции управления КА
-export([login/0]).

main() ->
  io:format("Please, create node on another terminal %get%@%system_name%~n"),
  PGet = list_to_atom("get@"++net_adm:localhost()),
  net_kernel:start(sndr,#{name_domain => shortnames}),
  register(sndr, self()),
  net_kernel:connect_node(PGet),
  case rpc:call(PGet, ?MODULE, readf,["number.txt"]) of
    {badrpc, Reason} -> io:format("Can't handle call, because:~p",[Reason]);
    Res -> io:format("Out result:~p",[Res])
  end.

readf(FILE) ->
  {Result, OUT} = file:open(FILE, [read]),
  if Result == ok ->
    try
      [Line|_] = string:split(io:get_line(OUT, "promt"),"\n", all),
      list_to_integer(Line)
    after file:close(OUT)
    end;
    true -> io:format("File doesn't exported!~nResult:~p Info:~p~n",[Result, OUT])
  end.

name() -> fsm. % The registered server name

%% API.  Функции изменения состояния
start() ->
  net_kernel:start(server, #{name_domain => shortnames}),
  register(server,self()),
  self() ! listen,
  gen_statem:start({local,name()}, ?MODULE, [], []),
  listener().

recv() ->
  case gen_statem:call(name(), get_desc, 5000) of
    ok -> get_data();
    {timeout, _} -> io:format("Time waiting is out!~n")
  end.

get_data() ->
  case gen_statem:call(name(), get_data, 5000) of
    ok -> find();
    error -> io:format("File not found on server!~n");
    {timeout, _} -> io:format("Time opening is out!~n")
  end.

find() ->
  case gen_statem:call(name(), get_number, 1000) of
    ok -> answer();
    error -> io:format("File is empty!~n");
    {timeout, _} -> io:format("Time opening is out!~n")
  end.

answer() ->
  gen_statem:call(name(), answer, 1000).

stop() ->
  net_kernel:stop(),
  unregister(server),
  gen_statem:stop(name()).

%% Обязательные функции обратного вызова
terminate(_Reason, _State, _Data) ->
  void.
code_change(_Vsn, State, Data, _Extra) ->
  {ok,State,Data}.
init([]) ->
  %% Функция инициализации. После запуска программы устанавливаем состояния ожидания (wait)
  State = wait, Data = [],
  io:format("Create node, registered and ready for run~n"),
  {ok,State,Data}.
callback_mode()
  -> state_functions.

%%% Изменение состояний
wait({call,From}, get_desc, Data) ->
  io:format("Getting descriptor~n"),
  {next_state,open,Data,[{reply,From,ok}]};
wait(_EventType, {PID, Filename}, _OldData) ->
  io:format("From PID:~p received a request to read the file: ~p~n",[PID,Filename]),
  {keep_state,{PID, Filename}};
wait(EventType, EventContent, Data) ->
  io:format("Waiting goes wrong!~n"),
  handle_event(EventType, EventContent, Data).

open({call,From}, get_data, {PID, FileName}) ->
  io:format("Opening file: ~p~n",[FileName]),
  {Stat, IoD} = file:open(FileName, [read]),
  if Stat == ok ->
    {next_state,read,{PID, IoD},[{reply,From,ok}]};
    true -> PID ! {error, "File cannot be opened"},
            {next_state,wait,[],[{reply,From, error}]}
  end;
open(EventType, EventContent, Data) ->
  io:format("Opening goes wrong!~n"),
  handle_event(EventType, EventContent, Data).

read({call,From}, get_number, {PID, IoD}) ->
  io:format("Reading file...~n"),
  case string:split(io:get_line(IoD, "promt"),"\n", all) of
    [] -> PID ! {error, "Nothing to read!"}, {next_state,wait,[],[{reply,From,error}]};
    [Line|_] -> Number = list_to_integer(Line), {next_state,send,{PID, Number},[{reply,From,ok}]}
  end;
read(EventType, EventContent, Data) ->
  io:format("Reading goes wrong!~n"),
  handle_event(EventType, EventContent, Data).

send({call,From}, answer, {PID, Number}) ->
  io:format("Sending number from file: ~p~n", [Number]),
  PID ! {number, Number},
  {next_state,wait,[],[{reply,From,wait}]};
send(EventType, EventContent, Data) ->
  io:format("Sending goes wrong!~n"),
  handle_event(EventType, EventContent, Data).

%% Обработка состояний
handle_event(Event, _, Data) ->
  io:format("Event: ~p~n",[Event]),
  {keep_state,Data}.

login() -> login(client).
login(Username) ->
  net_kernel:start(Username, #{name_domain => shortnames}),
  register(Username, self()),
  LocalFSM = list_to_atom("server@"++net_adm:localhost()),
  case net_adm:ping(LocalFSM) of
    pong -> proc(Username);
    pang -> io:format("Can't find server:~p~n",[LocalFSM]), logout(Username)
  end.

logout(Username) ->
  unregister(Username),
  net_kernel:stop(),
  LocalCli = list_to_atom(atom_to_list(Username)++"@"++net_adm:localhost()),
  io:format("Local client unregister:~p~n",[LocalCli]).

proc(Username) ->
  Name = atom_to_list(Username),
  case string:trim(io:get_line(Name++"> ")) of
    Msg when Msg == "!quit" -> io:format("Good bye!~n"), logout(Username);
    Msg when Msg == "!stop"-> {server,'server@MDS'} ! stop, logout(Username);
    Msg -> {server,'server@MDS'} !  {self(), start, Msg},
            receive
              {Resp, Info} -> io:format("Server response(~p): ~p~n", [Resp,Info])
            end,
            proc(Username)
  end.

listener() ->
  receive
    listen -> io:format("Server is ready to listen~n"), listener();
    stop -> stop(), io:format("FSM is stoped~n");
    {PID, start, File} ->
      PID ! "Server receive descriptor!",
      name() ! {PID, File},
      timer:sleep(2000),
      recv(),
      io:format("Server is ready to listen again~n"),
      listener();
    _ -> io:format("Wrong format~n"), listener()
  after 5000 ->
    listener()
  end.
