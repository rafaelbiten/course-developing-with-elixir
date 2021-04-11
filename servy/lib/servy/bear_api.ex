defmodule Servy.BearApi do
  @moduledoc false

  alias Servy.Conn
  alias Servy.Wildthings

  def index(%Conn{} = conn) do
    bears =
      Wildthings.list_bears()
      |> Poison.encode!()

    %{conn | status: 200, resp_body: bears, resp_content_type: "application/json"}
  end

  def create(%Conn{} = conn, %{"type" => type, "name" => name} = _params) do
    resp_body = "Created a #{type} bear named #{name}!"
    %{conn | status: 201, resp_body: resp_body}
  end
end
