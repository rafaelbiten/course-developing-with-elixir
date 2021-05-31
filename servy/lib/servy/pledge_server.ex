defmodule Servy.PledgeServer do
  @pledge_server __MODULE__

  # client interface

  def start(initial_state \\ []) do
    pid = spawn(__MODULE__, :receive_loop, [initial_state])
    Process.register(pid, @pledge_server)
    pid
  end

  def create(name, amount) do
    send(@pledge_server, {self(), :create, name, amount})

    receive do
      {:ok, created_pledge_id} -> created_pledge_id
    end
  end

  def recent_pledges() do
    send(@pledge_server, {self(), :recent_pledges})

    receive do
      {:ok, pledges} -> pledges
    end
  end

  def total_pledged() do
    send(@pledge_server, {self(), :total_pledged})

    receive do
      {:ok, total_pledged} -> total_pledged
    end
  end

  # server

  def receive_loop(state) do
    receive do
      {sender, :create, name, amount} ->
        new_state = [{name, amount} | state]
        send(sender, {:ok, random_id()})
        receive_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:ok, Enum.take(state, 3)})
        receive_loop(state)

      {sender, :total_pledged} ->
        total_pledged =
          state
          |> Enum.map(fn {_name, amount} -> amount end)
          |> Enum.sum()

        send(sender, {:ok, total_pledged})
        receive_loop(state)

      _unexpected ->
        receive_loop(state)
    end
  end

  defp random_id do
    :rand.uniform()
    |> Float.to_string()
    |> String.split(".")
    |> Enum.at(1)
  end
end
