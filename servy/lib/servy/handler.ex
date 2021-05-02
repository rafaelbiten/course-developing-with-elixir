defmodule Servy.Handler do
  @moduledoc """
  A rudimentary module to handle HTTP requests.
  Serving as a bit of a playground to try different things/approaches.
  """

  alias Servy.BearApi
  alias Servy.BearCtrl
  alias Servy.VideoCam
  alias Servy.JsonPlaceholderApi

  # import Servy.Plugins,
  #   only: [rewrite_query_params: 1, rewrite_path: 1, track: 1, emojify_resp_body: 1]
  #   except: [rewrite_query_params: 1]
  #   only: :functions
  #   only: :macros

  alias Servy.Conn

  @path_to %{
    pages: Path.expand("pages", File.cwd!())
  }

  @doc "The main module handler."
  def handle(request) do
    request
    |> Servy.Parser.parse()
    |> Servy.Plugins.rewrite_query_params()
    |> Servy.Plugins.rewrite_path()
    |> route
    |> Servy.Plugins.track()
    |> Servy.Plugins.emojify_resp_body()
    |> format_response
  end

  # Implementation

  defp route(%Conn{method: "GET", path: "/raise"} = _conn) do
    raise "Unhandled Server Error"
  end

  defp route(%Conn{method: "GET", path: "/sleep/" <> time} = conn) do
    time
    |> String.to_integer()
    |> :timer.seconds()
    |> :timer.sleep()

    %{conn | status: 200, resp_body: "Done!"}
  end

  defp route(%Conn{method: "GET", path: "/snapshots"} = conn) do
    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(VideoCam, :get_snapshot, [&1]))
      |> Enum.map(&Task.await/1)

    %{conn | status: 200, resp_body: inspect(snapshots)}
  end

  defp route(%Conn{method: "GET", path: "/wildthings"} = conn) do
    %{conn | status: 200, resp_body: "Bears, Leões, Tigers"}
  end

  defp route(%Conn{method: "GET", path: "/api/bears"} = conn) do
    BearApi.index(conn)
  end

  defp route(%Conn{method: "GET", path: "/api/users"} = conn) do
    JsonPlaceholderApi.index(conn)
  end

  defp route(%Conn{method: "GET", path: "/api/users/" <> id} = conn) do
    params = Map.put(conn.params, "id", id)
    JsonPlaceholderApi.get_user(conn, params)
  end

  defp route(%Conn{method: "GET", path: "/bears"} = conn) do
    BearCtrl.index(conn)
  end

  defp route(%Conn{method: "GET", path: "/bears/" <> id} = conn) do
    params = Map.put(conn.params, "id", id)
    BearCtrl.show(conn, params)
  end

  defp route(%Conn{method: "POST", path: "/bears"} = conn) do
    BearCtrl.create(conn, conn.params)
  end

  defp route(%Conn{method: "POST", path: "/api/bears"} = conn) do
    BearApi.create(conn, conn.params)
  end

  defp route(%Conn{method: "DELETE", path: "/bears/" <> id} = conn) do
    params = Map.put(conn, "id", id)
    BearCtrl.delete(conn, params)
  end

  defp route(%Conn{method: "GET", path: "/bears/new"} = conn) do
    Servy.FileHandler.handle_file(conn, %{path: @path_to.pages, file: "form.html"})
  end

  defp route(%Conn{method: "GET", path: "/pages/" <> page} = conn) do
    Servy.FileHandler.handle_file(conn, %{path: @path_to.pages, file: "#{page}.html"})
  end

  defp route(%Conn{method: "GET", path: "/about"} = conn) do
    Servy.FileHandler.handle_file(conn, %{path: @path_to.pages, file: "about.html"})
  end

  defp route(%Conn{path: path} = conn) do
    %{conn | status: 404, resp_body: "The resource for #{path} could not be found."}
  end

  defp format_response(%Conn{} = conn) do
    """
    HTTP/1.1 #{Conn.full_status(conn)}\r
    Content-Type: #{conn.resp_content_type};charset=utf-8\r
    Content-Length: #{byte_size(conn.resp_body)}\r
    \r
    #{conn.resp_body}
    """
  end
end
