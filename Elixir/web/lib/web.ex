defmodule Web do
  @moduledoc """
  Web server module
  Function list:
  - conn_db/1
  - read_base/2
  - json_conv/2
  - main/0 -
  - exe/2 -
  - get_page/2
  - get_user/2
  - response/3
  """

  @doc """
  The function of accessing the database and obtaining information about users
  Accept data base user id or 0 by default if we need all base
  """
  @spec conn_db(number()) :: map()
  def conn_db(id \\ 0) do
    {:ok, pid} = MyXQL.start_link(host: "localhost", port: 3300, username: "root", password: "1111", database: "erl")
    read_base(pid, id)
  end

  @doc """
  Getting data base data function
  """
  @spec read_base(pid(), number()) :: map()
  def read_base(pid, id) do
    case id do
      0 ->
        IO.puts "Getting all users"
        {:ok, result_map} = MyXQL.query(pid, "SELECT * FROM users")
        cols = result_map.columns
        rows = result_map.rows
        map = Enum.map(rows, fn x -> Enum.zip(cols, x) end)
        data = json_conv(map)
        JSON.encode(data)
      _ ->
        {:ok, result_map} = MyXQL.query(pid, "SELECT * FROM users WHERE id = #{id}")
        columns = result_map.columns
        [row] = result_map.rows
        case row do
          [] -> :empty
          _ ->
            data = Enum.into(Enum.zip(columns, row), %{})
            JSON.encode(data)
        end
    end
  end

  @doc """
  JSON convertation function from data base data to formated map
  """
  @spec json_conv(list(), map()) :: map()
  def json_conv([], res \\ %{}), do: res
  def json_conv([head | tail], res) do
    [{"id", id} | data] = head
    new_map = Map.put(res, "id-#{id}", Map.new(data))
    json_conv(tail, new_map)
  end

  @doc """
  Main server function
  Open listening port and start process of responding
  """
  @spec start_link(term()) :: :ok
  def start_link(port) do
    {:ok, listen_socket} = :gen_tcp.listen(port, [])
    IO.puts "Web-server start on #{port} port"
    Enum.to_list(1..5) |> Enum.map(fn id -> spawn(fn -> exe(listen_socket, id) end) end)
    {:ok, Kernel.self()}
  end

  @doc """
  Web server working function
  Accept Listening socket and web server id
  """
  @spec exe(term(), number()) :: nil
  def exe(lsoc, id) do
    IO.puts "Process ##{id} is ready"
    {:ok, socket} = :gen_tcp.accept(lsoc)
    receive do
      {:tcp, socket, 'GET ' ++ res} ->
        request = to_string(res)
        IO.puts "Process ##{id} GET: #{request}"
        [req | _] = String.split(request, " ", trim: true)
        case String.split(req, "/", trim: true) do
          [comm, n] when comm == "get_user" ->
            IO.puts "Request user #{n}"
            get_user(n, socket)
          page ->
            IO.puts "Another request #{page}"
            get_page(req, socket)
        end
      another ->
        IO.inspect(another, label: "Process ##{id} has corrupted request")
        ans = "405 Not Supported"
        response(socket, ans, ans)
    end
    :gen_tcp.close(socket)
    IO.puts "Process ##{id} work is done!"
    exe(lsoc, id)
  end

  @doc """
  Function for response on any request exept "/get_user/%id"
  """
  @spec get_page(String.t(), term()) :: :ok | {:error, term()}
  def get_page(page, socket) do
    {:ok, dir} = File.cwd()
    file = dir <> "/www" <> page
    IO.puts "Page: #{file}"
    file_info = case :file.read_file_info(file) do
      {:ok, {_, _, :regular, _, _, _, _, _, _, _, _, _, _, _}} -> :correct
      {:ok, _} -> "500 Server Error"
      _ -> "404 File Not Found"
    end
    case file_info do
      :correct ->
        head = case String.reverse(file) do
          "lmth." <> _ -> "text/html"
          "txt." <> _ -> "text/plain"
          _ -> "application/octet-stream"
        end
        resp = "200 OK\r\nContent-Type: " <> head
        response(socket, resp, [])
        :file.sendfile(file, socket)
      error ->
        response(socket, error, error)
    end
  end

  @doc """
  Function for response on "/get_user/%id" request
  """
  @spec get_user(number(), term()) :: :ok | {:error, term()}
  def get_user(n, socket) do
    IO.puts "Getting user##{n}"
    user = String.to_integer(n)
    answer = case conn_db(user) do
      :empty -> "User not found!"
      {:ok, jdata} -> jdata
    end
    response(socket, answer, answer)
  end

  @doc """
  Function for sending web server answer to user
  """
  @spec response(term(), String.t(), term()) :: :ok | {:error, term()}
  def response(socket, head, data) do
    :gen_tcp.send(socket, ["HTTP/1.1 ", head, "\r\n\r\n", data])
  end
end
