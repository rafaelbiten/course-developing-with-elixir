defmodule Servy.BearCtrl do
  alias Servy.Conn
  alias Servy.Wildthings

  def index(%Conn{} = conn) do
    bear_items =
      Wildthings.list_bears()
      |> Enum.map(fn bear -> "<li>#{bear.name} - #{bear.type}</li>" end)
      |> Enum.join()

    %{conn | status: 200, resp_body: "<ul>#{bear_items}</ul>"}
  end

  def show(%Conn{} = conn, %{"id" => id} = _params) do
    case Wildthings.get_bear(id) do
      nil -> %{conn | status: 404, resp_body: "Unknown Bear with id '#{id}'"}
      bear -> %{conn | status: 200, resp_body: "#{bear.name} Bear"}
    end
  end

  def create(%Conn{} = conn, %{"type" => type, "name" => name} = _params) do
    resp_body = "Created a #{type} bear named #{name}"
    %{conn | status: 201, resp_body: resp_body}
  end
end
