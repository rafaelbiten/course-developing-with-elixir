defmodule Servy.HttpServerTest do
  use ExUnit.Case, async: true
  doctest Servy.HttpServer
  alias Servy.HttpServer

  @tag :capture_log
  test "accepts a request on a socket and sends back a response" do
    port = start_server()

    Task.async(Tesla, :get, ["http://localhost:#{port}/wildthings"])
    |> Task.await()
    |> assert_response()
  end

  @tag :capture_log
  test "accepts and handles multiple concurrent requests" do
    port = start_server()

    1..5
    |> Enum.to_list()
    |> Enum.map(fn _ -> Task.async(Tesla, :get, ["http://localhost:#{port}/wildthings"]) end)
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_response/1)
  end

  defp start_server do
    port = Enum.random(1024..2000)
    spawn(HttpServer, :start, [port])
    port
  end

  defp assert_response({:ok, response}) do
    assert response.status == 200
    assert response.body == "😃 Bears, Leões, Tigers 😃"
  end
end
