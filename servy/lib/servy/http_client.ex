defmodule Servy.HttpClient do
  @moduledoc """
  An "attempt" of a very rudimentary http client, but it has many flaws.
  Leaving it here for reference, but refer to Tesla (project dependency) instead.
  HTTPoison is also recommended, but opted for Tesla after checking both docs.
  """

  require Logger

  def send(:sleep, seconds), do: sleep_and_send(seconds)
  def send(:sleep), do: sleep_and_send(3)

  def send(:request), do: send("GET /bears HTTP/1.1")
  def send(:raise), do: send("GET /raise HTTP/1.1")

  def send(request) do
    address = 'localhost'
    options = [:binary, packet: :raw, active: false]

    case :gen_tcp.connect(address, 4000, options) do
      {:ok, socket} ->
        :ok = :gen_tcp.send(socket, request)

        result = :gen_tcp.recv(socket, 0)
        :ok = :gen_tcp.close(socket)

        case result do
          {:ok, response} ->
            Logger.info(response)
            response

          {:error, reason} ->
            Logger.error("Failed with reason: #{reason}")
            reason
        end

      {:error, reason} ->
        raise """
        Failed to send request with reason '#{reason}'.
        Please make sure the server is running.
        """
    end
  end

  def send, do: send(:request)

  defp sleep_and_send(seconds) do
    send("GET /sleep/#{seconds} HTTP/1.1")
  end
end
