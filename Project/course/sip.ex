defmodule Sip do
  @moduledoc false
  @doc """
  Main server function
  Open listening port and start process of responding
  """
  @spec start_link(term()) :: :ok
  def start_link(port) do
    {:ok, listen_socket} = :gen_tcp.listen(port, [])
    exe(listen_socket, 1)
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
      data -> IO.inspect(data, label: "Data")
    end
    :gen_tcp.close(socket)
    IO.puts "Process ##{id} work is done!"
    exe(lsoc, id)
  end
end
