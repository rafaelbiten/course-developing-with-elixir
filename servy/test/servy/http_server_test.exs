defmodule Servy.HttpServerTest do
  use ExUnit.Case
  doctest Servy.HttpServer
  alias Servy.HttpClient
  alias Servy.HttpServer

  @tag :capture_log
  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [4000])
    response = HttpClient.send("GET /wildthings HTTP/1.1")

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 31\r
    \r
    😃 Bears, Leões, Tigers 😃
    """
  end
end
