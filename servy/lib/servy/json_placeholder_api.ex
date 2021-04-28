defmodule Servy.JsonPlaceholderApi do
  use Tesla

  # plug(Tesla.Middleware.JSON, engine: Poison)
  plug(Tesla.Middleware.BaseUrl, "https://jsonplaceholder.typicode.com")

  alias Servy.Conn

  def index(%Conn{} = conn) do
    get("/users") |> handle_response(conn)
  end

  def get_user(%Conn{} = conn, %{"id" => id} = _params) do
    get("/users/" <> id) |> handle_response(conn)
  end

  defp handle_response({:ok, response}, %Conn{} = conn),
    do: %{
      conn
      | status: response.status,
        resp_body: response.body,
        resp_content_type: "application/json"
    }

  defp handle_response({:error, reason}, %Conn{} = conn),
    do: %{conn | status: 500, resp_body: "Internal server error: #{reason}"}
end
