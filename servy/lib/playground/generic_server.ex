defmodule Playground.GenericServer do
  @moduledoc """
  A simplified implementation of how GenServers work internally
  """

  @doc """
  https://hexdocs.pm/elixir/GenServer.html#callbacks

  use GenServer

  handle_call(message, from = {pid, tag}, state)
    {:reply, reply, new_state}
    {:stop, reason, new_state}
    defaut: {:stop, {:bad_call, msg}, state}

  handle_cast(message, state)
    {:noreply, new_state}
    {:stop, reason, new_state}
    default: {:stop, {:bad_cast, msg}, state}

  handle_info(message, state)
    # used to handle all other requests
    default: {:noreply, state}

  init(initial_state)
    # called after GenServer.start(__MODULE__, initial_state, name: @name)
    # The GenServer will block and wait until the call to init is resolved
    default: def init(initial_state), do: {:ok, initial_state}

  terminate(reason, state)
    # should be use to do cleanup on server termination
    # - close a resource that was being used
    # - store the current state or send it elsewhere
    default: def terminate(_reason, _state), do: :ok
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
