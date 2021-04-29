defmodule Servy.HttpServerTest do
  use ExUnit.Case
  doctest Servy.HttpServer
  alias Servy.HttpServer

  # Skipping the test for now. Having issues with the port and error handling

  @tag :capture_log
  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [4000])

    {:ok, response} = Tesla.get("http://localhost:4000/wildthings")

    assert response.status == 200
    assert response.body == "😃 Bears, Leões, Tigers 😃"
  end
end
