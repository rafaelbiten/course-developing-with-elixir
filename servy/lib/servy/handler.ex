defmodule Servy.Handler do
  @moduledoc """
  A rudimentary module to handle HTTP requests.
  Serving as a bit of a playground to try different things/approaches.
  """

  alias Servy.BearCtrl

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
    |> IO.inspect()
    |> Servy.Plugins.rewrite_query_params()
    |> Servy.Plugins.rewrite_path()
    |> route
    |> Servy.Plugins.track()
    |> Servy.Plugins.emojify_resp_body()
    |> format_response
    |> IO.puts()
  end

  # Implementation

  defp route(%Conn{method: "GET", path: "/wildthings"} = conn) do
    %{conn | status: 200, resp_body: "Bears, Leões, Tigers"}
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
    HTTP/1.1 #{Conn.full_status(conn)}
    Content-Type: text/html
    Content-Length: #{byte_size(conn.resp_body)}

    #{conn.resp_body}
    """
  end
end

Enum.each(
  [
    """
    GET /wildthings HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /wildlife HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /bears?id=1 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /unknown HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /bears HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /bears/1 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    DELETE /bears/1 HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /about HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /bears/new HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    GET /pages/about HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """,
    """
    POST /bears HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    name=Zoom&type=Brown
    """
  ],
  &Servy.Handler.handle/1
)
