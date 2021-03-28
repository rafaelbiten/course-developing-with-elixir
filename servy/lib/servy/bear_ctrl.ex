defmodule Servy.BearCtrl do
  alias Servy.Conn
  alias Servy.Wildthings

  @spec index(Conn.t()) :: Conn.t()
  def index(%Conn{} = conn) do
    bears_by_name_asc = fn bear1, bear2 -> bear1.name <= bear2.name end
    bear_to_list_item = fn bear -> "<li>#{bear.name} - #{bear.type}</li>" end

    bear_items =
      Wildthings.list_bears()
      |> Enum.sort(bears_by_name_asc)
      |> Enum.map(bear_to_list_item)
      |> Enum.join()

    %{conn | status: 200, resp_body: "<ul>#{bear_items}</ul>"}
  end

  def show(%Conn{} = conn, %{"id" => id} = _params) do
    case Wildthings.get_bear(id) do
      nil -> %{conn | status: 404, resp_body: "Bear with id '#{id}' not found!"}
      bear -> %{conn | status: 200, resp_body: "#{bear.name} Bear"}
    end
  end

  def create(%Conn{} = conn, %{"type" => type, "name" => name} = _params) do
    resp_body = "Created a #{type} bear named #{name}"
    %{conn | status: 201, resp_body: resp_body}
  end

  def delete(%Conn{} = conn, _params) do
    %{conn | status: 403, resp_body: "It's forbidden to delete bears."}
  end
end
