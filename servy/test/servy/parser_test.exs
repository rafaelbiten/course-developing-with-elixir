defmodule Servy.ParserTest do
  use ExUnit.Case, async: true
  doctest Servy.Parser
  alias Servy.Parser

  test "parses a raw_request into a %Servy.Conn{}" do
    raw_request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=Zoom&type=Brown
    """

    assert Parser.parse(raw_request) == %Servy.Conn{
             headers: %{
               "Accept" => "*/*",
               "Content-Length" => "21",
               "Content-Type" => "application/x-www-form-urlencoded",
               "Host" => "example.com",
               "User-Agent" => "ExampleBrowser/1.0"
             },
             method: "POST",
             params: %{"name" => "Zoom", "type" => "Brown"},
             path: "/bears",
             resp_body: "",
             status: nil
           }
  end

  test "parses a raw_request empty body into a params empty map" do
    raw_request = """
    GET /bear/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21
    """

    assert Parser.parse(raw_request).params == %{}
  end
end
