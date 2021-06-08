defmodule Servy.PledgeServer do
  @pledge_server __MODULE__

  # alias Playground.GenericServer
  use GenServer

  # client interface

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_link(initial_state \\ []) do
    # GenericServer.start(__MODULE__, initial_state, @pledge_server)
    GenServer.start(__MODULE__, initial_state, name: @pledge_server)
  end

  def create(name, amount) do
    GenServer.call(@pledge_server, {:create, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@pledge_server, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@pledge_server, :total_pledged)
  end

  def ping() do
    GenServer.call(@pledge_server, :ping)
  end

  def clear_pledges() do
    GenServer.cast(@pledge_server, :clear_pledges)
  end

  # server callbacks

  def handle_call(:total_pledged, _from, state) do
    total_pledged =
      state
      |> Enum.map(fn {_name, amount} -> amount end)
      |> Enum.sum()

    {:reply, total_pledged, state}
  end

  def handle_call({:create, name, amount}, _from, state) do
    new_state = [{name, amount} | state]
    {:reply, random_id(), new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, Enum.take(state, 3), state}
  end

  def handle_call(:clear_pledges, _from, _state) do
    {:reply, :ok, []}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  def handle_cast(:clear_pledges, _state) do
    {:noreply, []}
  end

  defp random_id do
    :rand.uniform()
    |> Float.to_string()
    |> String.split(".")
    |> Enum.at(1)
  end
end
