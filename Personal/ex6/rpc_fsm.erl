%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 25. май 2022 14:48
%%%-------------------------------------------------------------------
-module(rpc_fsm).
-behaviour(gen_statem).
-author("Dann Maj").

%% API
-export([main/0, readf/1]). % Функции работы через узлы
-export([wait/3, open/3, read/3, send/3]). %Состояния КА
-export([terminate/3, code_change/4, init/1, callback_mode/0]). %Обязательные функции обратного вызова
-export([start/0, recv/0, get_data/0, find/0, answer/0, stop/0]). %Функции управления КА
-export([make_u/0, unmake_u/0, listener/0]).

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
  net_kernel:start('server', #{name_domain => shortnames}),
  register(server,self()),
  self() ! listen,
  gen_statem:start({local,name()}, ?MODULE, [], []).
recv() ->
  gen_statem:call(name(), get_disc, 20000),
  get_data().
get_data() ->
  gen_statem:call(name(), get_data, 1000),
  find().
find() ->
  gen_statem:call(name(), get_number, 1000),
  answer().
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
wait({call,From}, get_disc, Data) ->
  io:format("I'm waiting!~n"),
  receive
    {PID, FileName} -> {next_state,open,{PID,FileName},[{reply,From,open}]};
    _ -> {keep_state,Data}
  end;
wait(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

open({call,From}, get_data, {PID, FileName}) ->
  io:format("I'm open file!~n"),
  {Stat, IoD} = file:open(FileName, [read]),
  if Stat == ok ->
    {next_state,read,{PID, IoD},[{reply,From,read}]};
    true -> PID ! {self(), "File cannot be opened"},
      {next_state,wait,[],[{reply,From,wait}]}
  end;
open(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

read({call,From}, get_number, {PID, IoD}) ->
  io:format("I'm reading!~n"),
  case string:split(io:get_line(IoD, "promt"),"\n", all) of
    [] -> PID ! {self(), "Nothing to read!"}, {next_state,wait,[],[{reply,From,wait}]};
    [Line|_] -> Number = list_to_integer(Line), {next_state,send,{PID, Number},[{reply,From,send}]}
  end;
read(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

send({call,From}, answer, {PID, Number}) ->
  io:format("I'm sending!~n"),
  PID ! {self(), {number, Number}},
  {next_state,wait,[],[{reply,From,wait}]};
send(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

%% Обработка состояний
handle_event(_, _, Data) ->
  %% Игнорируем любые события
  {keep_state,Data}.

make_u() ->
  net_kernel:start(client, #{name_domain => shortnames}),
  register(client, self()),
  LocalFSM = list_to_atom("server@"++net_adm:localhost()),
  case net_adm:ping(LocalFSM) of
    pong -> {fsm,LocalFSM} ! {self(), "Its me!"};
    pang -> io:format("Can't find server:~p~n",[LocalFSM])
  end.

unmake_u() ->
  unregister(client),
  net_kernel:stop(),
  LocalCli = list_to_atom("client"++net_adm:localhost()),
  io:format("Local client unregister:~p~n",[LocalCli]).

listener() ->
  receive
    listen -> io:format("Server is ready to listen~n"), listener();
    stop -> stop(), io:format("FSM is stoped");
    {PID, start, File} -> PID ! "Get it!", name() ! {PID, File}, recv();
    _ -> io:format("Wrong format~n"), listener()
  after 5000 ->
    listener()
  end.
