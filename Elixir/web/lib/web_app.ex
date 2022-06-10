defmodule Web.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Web.Supervisor.start_link([])
  end
end