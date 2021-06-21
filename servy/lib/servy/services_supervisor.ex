defmodule Servy.ServicesSupervisor do
  use Supervisor

  alias Servy.Count404s
  alias Servy.PledgeServer
  alias Servy.SensorServer
  alias Servy.HttpServerGenServer

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Count404s,
      PledgeServer,
      {SensorServer,
       %SensorServer.State{
         refresh_interval: :timer.minutes(10)
       }},
      HttpServerGenServer
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
