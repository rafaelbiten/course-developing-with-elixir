defmodule Servy.BearApi do
  alias Servy.Conn
  alias Servy.Wildthings

  def index(%Conn{} = conn) do
    bears =
      Wildthings.list_bears()
      |> Poison.encode!()

    %{conn | status: 200, resp_body: bears, content_type: "application/json"}
  end
end
