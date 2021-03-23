defmodule Servy.Parser do
  alias Servy.Conn, as: Conn

  def parse(request) do
    [method, path, _protocol] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %Conn{method: method, path: path}
  end
end
