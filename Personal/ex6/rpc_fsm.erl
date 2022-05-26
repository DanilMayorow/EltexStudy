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
-export([main/1, readf/1]).
-export([init/0, wait/3, open/1, read/1, send/1]).
-export([terminate/3,code_change/4,init/1,callback_mode/0]).

main(0) ->
  io:format("Please, create node on another terminal %get%@%system_name%~n"),
  PGet = list_to_atom("get@"++net_adm:localhost()),
  net_kernel:start(sndr,#{name_domain => shortnames}),
  register(sndr, self()),
  net_kernel:connect_node(PGet),
  case rpc:call(PGet, ?MODULE, readf,["number.txt"]) of
    {badrpc, Reason} -> io:format("Can't handle call, because:~p",[Reason]);
    Res -> io:format("Out result:~p",[Res])
  end;
main(1) ->
  spawn(init()).

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

init() ->
  io:format("Init FSM for reading files~n"),
  wait().

open({PID, FileName}) ->
  {Stat, IoD} = file:open(FileName, [read]),
  if Stat == ok ->
    read({PID, IoD});
    true -> PID ! {self(), "File cannot be opened"},
      wait()
  end.

read({PID, IoD}) ->
  case string:split(io:get_line(IoD, "promt"),"\n", all) of
    [] -> PID ! {self(), "Nothing to read!"}, wait();
    [Line|_] -> Number = list_to_integer(Line), send({PID, Number})
  end.

send({PID, Number}) ->
  PID ! {self(), {number, Number}},
  wait().

name() -> pushbutton_statem. % The registered server name

%% API.  Функции изменения состояния
start() ->
  gen_statem:start({local,name()}, ?MODULE, [], []).
push() ->
  gen_statem:call(name(), push),
  get().
get() ->
  gen_statem:call(name(), get_data),
  find().
find() ->
  gen_statem:call(name(), get_number),
  answer().
answer() ->
  gen_statem:call(name(), answer).
stop() ->
  gen_statem:stop(name()).

%% Обязательные функции обратного вызова
terminate(_Reason, _State, _Data) ->
  void.
code_change(_Vsn, State, Data, _Extra) ->
  {ok,State,Data}.
init([]) ->
  State = off, Data = 0,
  {ok,State,Data}.
callback_mode()
  -> state_functions.

%%% Изменение состояний
wait({call,From}, get_disc, Data) ->
  receive
    {PID, FileName} -> {next_state,open,{PID,FileName},[{reply,From,open}]};
    _ -> {keep_state,Data}
  after 10000 ->
    {keep_state,Data}
  end;
wait(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

open({call,From}, get_data, Data) ->
  {next_state,read,Data+1,[{reply,From,read}]};
open(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

read({call,From}, answer, Data) ->
  {next_state,send,Data+1,[{reply,From,send}]};
read(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

send({call,From}, send, {PID, Number}) ->
  PID ! {self(), {number, Number}},
  {next_state,wait,[],[{reply,From,wait}]};
send(EventType, EventContent, Data) ->
  handle_event(EventType, EventContent, Data).

%% Обработка состояний
handle_event({call,From}, get_count, Data) ->
  {keep_state,Data,[{reply,From,Data}]};
handle_event(_, _, Data) ->
  %% Ignore all other events
  {keep_state,Data}.