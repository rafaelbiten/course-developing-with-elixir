defmodule Servy.BearCtrl do
  alias Servy.Conn
  alias Servy.Wildthings

  @templates_path Path.expand("templates", File.cwd!())

  @spec index(Conn.t()) :: Conn.t()
  def index(%Conn{} = conn) do
    bears_by_name_asc = fn bear1, bear2 -> bear1.name <= bear2.name end
    # bear_to_list_item = fn bear -> "<li>#{bear.name} - #{bear.type}</li>" end

    bears =
      Wildthings.list_bears()
      |> Enum.sort(bears_by_name_asc)

    resp_body =
      @templates_path
      |> Path.join("index.eex")
      |> EEx.eval_file(bears: bears)

    %{conn | status: 200, resp_body: resp_body}
  end

  def show(%Conn{} = conn, %{"id" => id} = _params) do
    case Wildthings.get_bear(id) do
      nil ->
        %{conn | status: 404, resp_body: "Bear with id '#{id}' not found!"}

      bear ->
        resp_body =
          @templates_path
          |> Path.join("show.eex")
          |> EEx.eval_file(bear: bear)

        %{conn | status: 200, resp_body: resp_body}
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
