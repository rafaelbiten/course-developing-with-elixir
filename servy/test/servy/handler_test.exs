defmodule Servy.HandlerTest do
  use ExUnit.Case
  doctest Servy.Handler
  alias Servy.Handler

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    assert Servy.Handler.handle(request) == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 31\r
           \r
           😃 Bears, Leões, Tigers 😃
           """
  end
end
