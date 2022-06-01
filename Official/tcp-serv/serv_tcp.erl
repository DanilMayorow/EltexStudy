%%%-------------------------------------------------------------------
%%% @author Dann Maj
%%% @copyright (C) 2022, <Eltex>
%%% @doc
%%%
%%% @end
%%% Created : 01. июнь 2022 14:58
%%%-------------------------------------------------------------------
-module(serv_tcp).
-author("Dann Maj").

%% API
-export([main/0]).

main() ->
  {ok, ListenSocket} = gen_tcp:listen(8080, []), exe(ListenSocket).
exe(LSocket) ->
  {ok, Socket} = gen_tcp:accept(LSocket),
  receive
    {tcp, Socket, "GET " ++ R} ->
      io:format("~p~n",[R]),
      [Page | _] = string:tokens(R, " "),
      {ok, Dir} = file:get_cwd(),
      F = Dir ++ "/www" ++ Page,
      io:format("~p~n",[F]),
      case
        case file:read_file_info(F) of
          {ok, {_, _, regular, _, _, _, _, _, _, _, _, _, _, _}} -> a;
          {ok, _} -> "500 Server Error";
          _ -> "404 File Not Found"
        end
      of
        a -> response(Socket, "200 OK\r\nContent-Type: "
        ++ case lists:reverse(F) of
             "lmth." ++ _ -> "text/html";
             "txt." ++ _ -> "text/plain";
             _ -> "application/octet-stream" end, []), file:sendfile(F, Socket);
        E -> response(Socket, E, E)
      end;
    _ -> E = "405 Not Supported", response(Socket, E, E)
  end,
  gen_tcp:close(Socket), exe(LSocket).

response(S, H, B) ->
  gen_tcp:send(S, ["HTTP/1.1 ", H, "\r\n\r\n", B]).
