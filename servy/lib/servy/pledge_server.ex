defmodule Servy.PledgeServer do
  @pledge_server __MODULE__

  alias Playground.GenericServer

  # client interface

  def start(initial_state \\ []) do
    GenericServer.start(__MODULE__, initial_state, @pledge_server)
  end

  def create(name, amount) do
    GenericServer.call(@pledge_server, {:create, name, amount})
  end

  def recent_pledges() do
    GenericServer.call(@pledge_server, :recent_pledges)
  end

  def total_pledged() do
    GenericServer.call(@pledge_server, :total_pledged)
  end

  def ping() do
    GenericServer.call(@pledge_server, :ping)
  end

  def clear_pledges() do
    GenericServer.cast(@pledge_server, :clear_pledges)
  end

  # server callbacks

  def handle_call(:total_pledged, state) do
    total_pledged =
      state
      |> Enum.map(fn {_name, amount} -> amount end)
      |> Enum.sum()

    {total_pledged, state}
  end

  def handle_call({:create, name, amount}, state) do
    new_state = [{name, amount} | state]
    {random_id(), new_state}
  end

  def handle_call(:recent_pledges, state) do
    {Enum.take(state, 3), state}
  end

  def handle_call(:clear_pledges, _state) do
    {:ok, []}
  end

  def handle_call(:ping, state) do
    {:pong, state}
  end

  def handle_cast(:clear_pledges, _state) do
    []
  end

  defp random_id do
    :rand.uniform()
    |> Float.to_string()
    |> String.split(".")
    |> Enum.at(1)
  end
end
