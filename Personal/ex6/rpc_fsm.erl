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
-export([main/0, readf/1]).

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
