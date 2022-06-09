defmodule Web do
  @moduledoc """
  Documentation for `Web`.
  """

  @doc """

  """
  defp conn_db(id) do
    {:ok, pid} = MyXQL.start_link(host: "localhost", port: 3300, username: "root", password: "1111", database: "erl")
    read_base(pid, id)
  end

  def read_base(pid, id) do
    {:ok, result_map} = MyXQL.query(pid, "SELECT * FROM users WHERE id = #{id}}")
  end

  @doc """
      read_rows(Rows) -> read_rows(Rows, maps:new()).
  read_rows([], Res) -> Res;
  read_rows([H|T], Map) ->
  [ID, Name, Age, Phone] = H, read_rows(T, maps:put(ID, [Name, Age, Phone], Map)).
  """
  defp read_rows(rows) do
    
  end

  def main do
    {:ok, listen_socket} = :gen_tcp.listen(8080, [])
    #Enum.to_list(1..5) |> Enum.map(fn id-> spawn(fn -> Web.exe(listen_socket, id) end) end)
    exe(listen_socket, 1)
    :ok
  end

  @doc """

  """

  defp exe(lsoc, id) do
    IO.puts "Process ##{id} is ready"
    {:ok, socket} = :gen_tcp.accept(lsoc)
    receive do
      {:tcp, socket, "GET "<> res} ->
      IO.puts "Process ##{id} GET:#{res}"
      [req | _ ] = String.split(res, " ")
      case String.split(req, "/") do
        [comm, n] when comm == "get_user" ->
          IO.puts "Request user #{n}"
          #get_user(req, socket)
        page ->
          IO.puts "Another request #{page}"
          #get_page(req, socket)
      end
      _ ->
      IO.puts "Process ##{id} has corrupted request"
      ans = "405 Not Supported"
      response(socket, ans, ans)
    end
    :gen_tcp.close(socket)
    IO.puts "Process ##{id} work is done!}"
    exe(lsoc,id)
  end

  @doc """
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
  """
  defp get_page(page, socket) do

  end

  @doc """
  get_user(N, Socket) ->
  io:format("Getting user~n"),
  UserMap = connect(),
  io:format("~p~n",[UserMap]),
  Key = list_to_integer(N),
  case maps:find(Key, UserMap) of
    error -> Ans = "User Not Found", response(Socket, Ans, Ans);
    {ok, Data} -> Resp=convert(N,Data), response(Socket, Resp, Resp)
  end.
  """
  defp get_user(n, socket) do

  end

  @doc """
  response(S, H, B) ->
  gen_tcp:send(S, ["HTTP/1.1 ", H, "\r\n\r\n", B]).
  """
  defp response(s, h, b) do

  end

  @doc """
    convert(Num,[Name,Age,Phone]) ->
  "USER #"++Num++" DATA:\n"
    ++"Name: " ++binary_to_list(Name)
    ++"\nAge: "++integer_to_list(Age)
    ++"\nPhone: "++integer_to_list(trunc(Phone)).
  """
  defp convert(n, [name,age,phone]) do

  end

end
