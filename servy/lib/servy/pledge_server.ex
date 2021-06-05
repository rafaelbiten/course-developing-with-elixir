defmodule Servy.PledgeServer do
  @pledge_server __MODULE__

  # client interface

  def start(initial_state \\ []) do
    pid = spawn(__MODULE__, :receive_loop, [initial_state])
    Process.register(pid, @pledge_server)
    pid
  end

  def create(name, amount) do
    call(@pledge_server, {:create, name, amount})
  end

  def recent_pledges() do
    call(@pledge_server, :recent_pledges)
  end

  def total_pledged() do
    call(@pledge_server, :total_pledged)
  end

  def clear_pledges() do
    cast(@pledge_server, :clear_pledges)
  end

  def ping() do
    call(@pledge_server, :ping)
  end

  # Helper Functions

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  # server

  def receive_loop(state) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = handle_call(message, state)
        send(sender, {:response, response})
        receive_loop(new_state)

      {:cast, message} ->
        new_state = handle_cast(message, state)
        receive_loop(new_state)

      _unexpected ->
        receive_loop(state)
    end
  end

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
