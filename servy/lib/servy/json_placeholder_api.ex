defmodule Servy.JsonPlaceholderApi do
  use Tesla

  plug(Tesla.Middleware.JSON, engine: Poison)
  plug(Tesla.Middleware.BaseUrl, "https://jsonplaceholder.typicode.com")

  alias Servy.Conn

  def index(%Conn{} = conn) do
    {:ok, response} = get("/users")
    resp_body = Poison.encode!(response.body)
    %{conn | status: 200, resp_body: resp_body, resp_content_type: "application/json"}
  end

  def get_user(%Conn{} = conn, %{"id" => id} = _params) do
    {:ok, response} = get("/users/" <> id)
    resp_body = Poison.encode!(response.body)
    %{conn | status: 200, resp_body: resp_body, resp_content_type: "application/json"}
  end
end
