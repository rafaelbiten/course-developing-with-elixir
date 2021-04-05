defmodule Servy.HandlerTest do
  use ExUnit.Case
  doctest Servy.Handler
  alias Servy.Handler

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*
    """

    assert Handler.handle(request) == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 31\r
           \r
           😃 Bears, Leões, Tigers 😃
           """
  end

  test "GET /wildlife rewrites path to /wildthings" do
    request = """
    GET /wildlife HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*
    """

    assert Handler.handle(request) == """
           HTTP/1.1 200 OK\r
           Content-Type: text/html\r
           Content-Length: 31\r
           \r
           😃 Bears, Leões, Tigers 😃
           """
  end

  test "GET /bears/1" do
    request = """
    GET /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    assert remove_whitespaces(response) ==
             remove_whitespaces("""
             HTTP/1.1 200 OK\r
             Content-Type: text/html\r
             Content-Length: 83\r
             \r
             😃<h1>ShowingBear</h1><p>IsTeddyhibernating?<strong>true</strong></p>😃
             """)
  end

  test "DELETE /bears/1" do
    request = """
    DELETE /bears/1 HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    assert Handler.handle(request) == """
           HTTP/1.1 403 Forbidden\r
           Content-Type: text/html\r
           Content-Length: 31\r
           \r
           It's forbidden to delete bears.
           """
  end

  test "404s" do
    request = """
    GET /unknown HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*
    """

    assert Handler.handle(request) == """
           HTTP/1.1 404 Not Found\r
           Content-Type: text/html\r
           Content-Length: 45\r
           \r
           The resource for /unknown could not be found.
           """
  end

  defp remove_whitespaces(text) do
    String.replace(text, ~r{\s}, "")
  end
end
