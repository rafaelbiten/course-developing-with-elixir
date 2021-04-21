defmodule Servy.HttpServer do
  @moduledoc false

  require Logger

  def start(port) when is_integer(port) and port > 1023 do
    # :binary - delivers data as binaries
    # backlog - queue size of max connection requests waiting to be handled
    # packet: :raw - delivers entire packet as it is received
    # active: false - waits for us to call :gen_tcp.recv/2 to deliver messages
    # reuseaddr: true - reuses address if the listener crashes
    options = [:binary, backlog: 10, packet: :raw, active: false, reuseaddr: true]
    {:ok, socket} = :gen_tcp.listen(port, options)

    Logger.info("\nListening on port #{port}...")

    listen(socket)
  end

  defp listen(socket) do
    Logger.info("Waiting to accept a client connection...\n")

    # Creates a new client_socket to process the request and free up the socket
    {:ok, client_socket} = :gen_tcp.accept(socket)

    Logger.info("Connection stablished!\n")

    spawn(fn -> serve(client_socket) end)

    listen(socket)
  end

  defp serve(client_socket) do
    client_socket
    |> receive_request
    |> Servy.Handler.handle()
    |> send_response(client_socket)
  end

  defp receive_request(client_socket) do
    # 0 to receive all available bytes
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, request} ->
        Logger.info("Request received: \n")
        Logger.info(request)
        request

      {:error, reason} ->
        Logger.info("Request error: \n")
        reason
    end
  end

  defp send_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)

    Logger.info("Response sent:\n")
    Logger.info(response)

    :gen_tcp.close(client_socket)
  end

  @doc """
  Example of converting an Erlang module into an Elixir module

  server() ->
    {ok, LSock} = gen_tcp:listen(5678, [binary, {packet, 0},
                                        {active, false}]),
    {ok, Sock} = gen_tcp:accept(LSock),
    {ok, Bin} = do_recv(Sock, []),
    ok = gen_tcp:close(Sock),
    ok = gen_tcp:close(LSock),
    Bin.

    Erlang          | Elixir
    ----------------------------------
    ok              | :ok
    Socket          | socket
    gen_tcp         | :gen_tcp
    gen_tcp:listen  | :gen_tcp.listen
    "hello"         | 'hello'
  """
  def _server do
    {:ok, lsock} = :gen_tcp.listen(5678, [:binary, packet: 0, active: false])
    {:ok, sock} = :gen_tcp.accept(lsock)
    {:ok, bin} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)
    :ok = :gen_tcp.close(lsock)
    bin
  end
end
