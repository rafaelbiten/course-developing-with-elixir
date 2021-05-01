defmodule Servy.HttpServerTest do
  use ExUnit.Case, async: true
  doctest Servy.HttpServer
  alias Servy.HttpServer

  @tag :capture_log
  test "accepts a request on a socket and sends back a response" do
    port = start_server()

    {:ok, response} = Tesla.get("http://localhost:#{port}/wildthings")

    assert response.status == 200
    assert response.body == "😃 Bears, Leões, Tigers 😃"
  end

  @tag :capture_log
  test "accepts and handles multiple concurrent requests" do
    parent = self()
    port = start_server()
    requests = 1..5

    for _ <- requests do
      spawn(fn -> send(parent, Tesla.get("http://localhost:#{port}/wildthings")) end)
    end

    for _ <- requests do
      assert_receive({:ok, response})
      assert response.status == 200
    end
  end

  defp start_server do
    port = Enum.random(1024..2000)
    spawn(HttpServer, :start, [port])
    port
  end
end
