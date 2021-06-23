defmodule Servy.HttpServerGenServer do
  @moduledoc """
  Servy.HttpServer is not a GenServer, so it can't be directly supervised.
  This HttpServerGenServer wraps the HttpServer into a GenServer for supervision.
  """

  @name __MODULE__

  use GenServer

  require Logger

  # Interface

  def start_link(_arg) do
    GenServer.start_link(@name, :ok, name: @name)
  end

  # Not using the genserver state
  def get_http_server_pid() do
    Process.whereis(Servy.HttpServer)
  end

  # Using the genserver state
  def get_http_server_pid_call() do
    GenServer.call(@name, :get_http_server_pid)
  end

  def init(:ok) do
    # trap exit signals from child processes and convert
    # them into info calls like {:EXIT, pid, reason}
    Process.flag(:trap_exit, true)

    pid = start_http_server()
    {:ok, pid}
  end

  # Implementation

  def handle_call(:get_http_server_pid, _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    Logger.warn("Servy.HttpServer exited with reason: #{inspect(reason)}")
    new_server_pid = start_http_server()
    {:noreply, new_server_pid}
  end

  defp start_http_server() do
    port = Application.fetch_env!(:servy, :port)
    pid = spawn_link(Servy.HttpServer, :start, [port])
    Process.register(pid, Servy.HttpServer)
    pid
  end
end
