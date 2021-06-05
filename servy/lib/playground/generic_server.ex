defmodule Playground.GenericServer do
  @moduledoc """
  A simplified implementation of how GenServers work internally
  """

  def start(callback_module, initial_state, server_name) do
    pid = spawn(__MODULE__, :receive_loop, [initial_state, callback_module])
    Process.register(pid, server_name)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  # Server

  def receive_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        receive_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        receive_loop(new_state, callback_module)

      _unexpected ->
        receive_loop(state, callback_module)
    end
  end
end
