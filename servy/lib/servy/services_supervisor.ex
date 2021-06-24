defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.Count404s,
      Servy.PledgeServer,
      {Servy.SensorServer,
       initial_state: %Servy.SensorServer.State{
         refresh_interval: :timer.minutes(10)
       }}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
