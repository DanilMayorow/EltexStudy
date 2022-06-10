defmodule Web.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_arg) do
    children = [
      %{
        id: WebMain,
        start: {Web, :start_link, [8080]},
        restart: :permanent,
        type: :worker
      },
      %{
        id: WebLocal,
        start: {Web, :start_link, [80]},
        restart: :transient,
        type: :worker
      },
      %{
        id: WebBackapp,
        start: {Web, :start_link, [8081]},
        restart: :temporary,
        type: :worker
      }
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end