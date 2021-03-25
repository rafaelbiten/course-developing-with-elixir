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
    [request_headers | params] = String.split(raw_request, "\n\n")
    [first_line_request | headers] = String.split(request_headers, "\n")
    [method, path, _protocol] = String.split(first_line_request, " ")

    %Conn{
      method: method,
      path: path,
      headers: parse_headers(headers, %{}),
      params: parse_params(params)
    }
  end

  defp parse_headers([], headers), do: headers

  defp parse_headers([x | xs], headers) do
    [key, value] = String.split(x, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(xs, headers)
  end

  defp parse_params(params) do
    List.first(params)
    |> String.trim()
    |> URI.decode_query()
  end
end
