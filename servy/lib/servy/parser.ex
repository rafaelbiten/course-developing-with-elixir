defmodule Servy.Parser do
  alias Servy.Conn, as: Conn

  def parse(raw_request) do
    [request_headers | request_data] = String.split(raw_request, "\n\n")
    [first_line_request | _headers] = String.split(request_headers, "\n")

    first_line_request
    |> parse_request()
    |> parse_request_data(request_data)
  end

  defp parse_request(request) do
    [method, path, _protocol] = String.split(request, " ")
    %Conn{method: method, path: path}
  end

  defp parse_request_data(%Conn{} = conn, request_data) do
    data =
      List.first(request_data)
      |> String.trim()
      |> URI.decode_query()

    %Conn{conn | data: data}
  end
end
