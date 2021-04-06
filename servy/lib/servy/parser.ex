defmodule Servy.Parser do
  alias Servy.Conn, as: Conn

  @moduledoc """
  Parses raw requests into a Servy.Conn Struct

  --------------------------------------------------
  POST /bears HTTP/1.1
  Host: example.com
  User-Agent: ExampleBrowser/1.0
  Accept: */*
  Content-Type: application/x-www-form-urlencoded
  Content-Length: 21

  name=Zoom&type=Brown
  --------------------------------------------------
  """

  def parse(raw_request) do
    [request_headers | params] = String.split(raw_request, "\r\n\r\n")
    [first_line_request | headers] = String.split(request_headers, "\r\n")
    [method, path, _protocol] = String.split(first_line_request, " ")

    headers = parse_headers(headers)
    params = parse_params(headers["Content-Type"], params)

    %Conn{
      method: method,
      path: path,
      headers: headers,
      params: params
    }
  end

  defp parse_headers(headers) do
    Enum.reduce(headers, %{}, fn header_item, parsed_headers ->
      case header_item do
        "" ->
          parsed_headers

        _ ->
          [key, value] = String.split(header_item, ": ")
          Map.put(parsed_headers, key, value)
      end
    end)
  end

  defp parse_params("application/x-www-form-urlencoded", [params]) do
    String.trim(params) |> URI.decode_query()
  end

  defp parse_params("application/json", [params]) do
    Poison.Parser.parse!(params, %{})
  end

  defp parse_params(_, _), do: %{}
end
