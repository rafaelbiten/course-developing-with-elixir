defmodule Servy.HttpClient do
  def send(:sleep, seconds), do: sleep_and_send(seconds)
  def send(:sleep), do: sleep_and_send(3)

  def send(:request), do: send("GET /bears HTTP/1.1")
  def send(:raise), do: send("GET /raise HTTP/1.1")

  def send(request) do
    address = 'localhost'
    options = [:binary, packet: :raw, active: false]
    {:ok, socket} = :gen_tcp.connect(address, 4000, options)

    :ok = :gen_tcp.send(socket, request)

    case :gen_tcp.recv(socket, 0) do
      {:ok, response} -> IO.inspect(response, label: "✅ Response")
      {:error, reason} -> IO.inspect(reason, label: "🔥 Reason")
    end

    :ok = :gen_tcp.close(socket)
  end

  def send, do: send(:request)

  defp sleep_and_send(seconds) do
    send("GET /sleep/#{seconds} HTTP/1.1")
  end
end
