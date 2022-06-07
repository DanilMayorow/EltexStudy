%%%-------------------------------------------------------------------
%%% @author dannmaj
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. июнь 2022 15:15
%%%-------------------------------------------------------------------
-module(base).
-author("Dann Maj").
-define(ServerPower, 10).

%% SQL API
-export([connect/0, read_base/1]).

%% WEB API
-export([main/0, exe/2]).

connect() ->
  {ok, PID} = mysql:start_link([{host, "localhost"}, {port, 3300}, {user, "root"}, {password, "1111"},{database, "erl"}]),
  read_base(PID).

read_base(PID) ->
  {ok, _Cols, Rows}= mysql:query(PID, <<"SELECT * FROM users">>),
  read_rows(Rows).

read_rows(Rows) -> read_rows(Rows, maps:new()).
read_rows([], Res) -> Res;
read_rows([H|T], Map) ->
  [ID, Name, Age, Phone] = H, read_rows(T, maps:put(ID, [Name, Age, Phone], Map)).

main() ->
  {ok, ListenSocket} = gen_tcp:listen(8080, []),
  [spawn(?MODULE,exe,[ListenSocket, ID]) || ID <- lists:seq(1, ?ServerPower)], ok.

exe(LSocket, ID) ->
  io:format("Process #~p is ready~n",[ID]),
  {ok, Socket} = gen_tcp:accept(LSocket),
  receive
    {tcp, Socket, "GET " ++ R} ->
      io:format("Process #~p GET: ~p~n",[ID,R]),
      [Req | _] = string:tokens(R, " "),
      case string:tokens(Req,"/") of
        [Comm, N] when Comm == "get_user" -> io:format("Request user #~p~n",[N]), get_user(N, Socket);
        Page -> io:format("Request other ~p~n", [Page]), get_page(Req, Socket)
      end;
    _ ->
      io:format("Process #~p has corrupted request~n",[ID]),
      E = "405 Not Supported", response(Socket, E, E)
  end,
  gen_tcp:close(Socket),
  io:format("Process #~p work is done!~n",[ID]),
  exe(LSocket, ID).

get_page(Page, Socket) ->
  {ok, Dir} = file:get_cwd(),
  F = Dir ++ "/www" ++ Page,
  io:format("Page: ~p~n",[F]),
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
  end.

get_user(N, Socket) ->
  io:format("Getting user~n"),
  UserMap = connect(),
  io:format("~p~n",[UserMap]),
  Key = list_to_integer(N),
  case maps:find(Key, UserMap) of
    error -> Ans = "User Not Found", response(Socket, Ans, Ans);
    {ok, Data} -> Resp=convert(N,Data), response(Socket, Resp, Resp)
  end.

response(S, H, B) ->
  gen_tcp:send(S, ["HTTP/1.1 ", H, "\r\n\r\n", B]).

convert(Num,[Name,Age,Phone]) ->
  "USER #"++Num++" DATA:\n"
    ++"Name: " ++binary_to_list(Name)
    ++"\nAge: "++integer_to_list(Age)
    ++"\nPhone: "++integer_to_list(trunc(Phone)).

