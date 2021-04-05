defmodule Servy.HandlerTest do
  use ExUnit.Case, async: true
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

  @tag :capture_log
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

    assert Handler.handle(request)
           |> contains("200 OK")
           |> contains("Showing Bear")
           |> contains("Is Teddy hibernating?")
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

  @tag :capture_log
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

  @tag :capture_log
  test "GET /api/bears" do
    request = """
    GET /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = Handler.handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: 605\r
    \r
    [{"type":"Brown","name":"Teddy","id":1,"hibernating":true},
     {"type":"Black","name":"Smokey","id":2,"hibernating":false},
     {"type":"Brown","name":"Paddington","id":3,"hibernating":false},
     {"type":"Grizzly","name":"Scarface","id":4,"hibernating":true},
     {"type":"Polar","name":"Snow","id":5,"hibernating":false},
     {"type":"Grizzly","name":"Brutus","id":6,"hibernating":false},
     {"type":"Black","name":"Rosie","id":7,"hibernating":true},
     {"type":"Panda","name":"Roscoe","id":8,"hibernating":false},
     {"type":"Polar","name":"Iceman","id":9,"hibernating":true},
     {"type":"Grizzly","name":"Kenai","id":10,"hibernating":false}]
    """

    assert remove_whitespace(response) == remove_whitespace(expected_response)
  end

  defp contains(content, pattern) do
    case String.contains?(content, pattern) do
      true -> content
      false -> raise "Content does not contain pattern: #{pattern}"
    end
  end

  defp remove_whitespace(string) do
    String.replace(string, ~r{\s}, "")
  end
end
