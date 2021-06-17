defmodule Servy.HttpServerGenServer do
  @moduledoc """
  Servy.HttpServer is not a GenServer, so it can't be directly supervised.
  This HttpServerGenServer wraps the HttpServer into a GenServer for supervision.
  """

  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # trap exit signals from child processes and convert
    # them into info calls like {:EXIT, pid, reason}
    Process.flag(:trap_exit, true)

    pid = start_http_server()
    {:ok, pid}
  end

  def handle_info({:EXIT, _pid, reason}, _state) do
    Logger.warn("Servy.HttpServer exited with reason: #{inspect(reason)}")
    new_server_pid = start_http_server()
    {:noreply, new_server_pid}
  end

  defp start_http_server() do
    pid = spawn_link(Servy.HttpServer, :start, [4000])
    Process.register(pid, Servy.HttpServer)
    pid
  end
end
