defmodule Servy.HttpClient do
  @request """
  GET /bears HTTP/1.1\r
  Host: example.com\r
  User-Agent: ExampleBrowser/1.0\r
  Accept: */*\r
  \r
  """

  def send(data \\ @request) do
    address = 'localhost'
    options = [:binary, packet: :raw, active: false]
    {:ok, socket} = :gen_tcp.connect(address, 4000, options)

    :ok = :gen_tcp.send(socket, data)

    case :gen_tcp.recv(socket, 0) do
      {:ok, response} -> IO.inspect(response, label: "✅ Response")
      {:error, reason} -> IO.inspect(reason, label: "🔥 Reason")
    end

    :ok = :gen_tcp.close(socket)
  end
end
