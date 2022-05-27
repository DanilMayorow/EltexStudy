%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 25. май 2022 14:48
%%%-------------------------------------------------------------------
-module(rpc_fsm).
-author("Dann Maj").

%% API
-export([main/1, readf/1]).
-export([init/0, wait/0, open/1, read/1, send/1]).

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

wait() ->
  receive
    {PID, FileName} -> io:format("OP!~n"),open({PID,FileName});
    Data -> io:format("Data:~p!~n",[Data]), wait()
  after 5000 ->
    io:format("I'm still wait!~n"),
    wait()
  end.

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