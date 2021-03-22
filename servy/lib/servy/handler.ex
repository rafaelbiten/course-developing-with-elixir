defmodule Servy.Handler do
  @moduledoc """
  A rudimentary module to handle HTTP requests.
  Serving as a bit of a playground to try different things/approaches.
  """

  # import Servy.Plugins,
  #   only: [rewrite_query_params: 1, rewrite_path: 1, track: 1, emojify_resp_body: 1]
  #   except: [rewrite_query_params: 1]
  #   only: :functions
  #   only: :macros

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

  defp route(%{method: "GET", path: "/wildthings"} = conn) do
    %{conn | status: 200, resp_body: "Bears, Leões, Tigers"}
  end

  defp route(%{method: "GET", path: "/bears"} = conn) do
    %{conn | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  defp route(%{method: "GET", path: "/bears/new"} = conn) do
    Servy.FileHandler.handle_file(conn, %{path: @path_to.pages, file: "form.html"})
  end

  defp route(%{method: "GET", path: "/pages/" <> page} = conn) do
    Servy.FileHandler.handle_file(conn, %{path: @path_to.pages, file: "#{page}.html"})
  end

  defp route(%{method: "GET", path: "/bears/" <> id} = conn) do
    bear =
      case id do
        "0" -> "Teddy"
        "1" -> "Smokey"
        "2" -> "Paddington"
        _ -> "Unknown"
      end

    %{conn | status: 200, resp_body: "#{bear} Bear"}
  end

  defp route(%{method: "GET", path: "/about"} = conn) do
    Servy.FileHandler.handle_file(conn, %{path: @path_to.pages, file: "about.html"})
  end

  defp route(%{method: "DELETE", path: "/bears/" <> _id} = conn) do
    %{conn | status: 403, resp_body: "It's forbidden to delete bears."}
  end

  defp route(%{path: path} = conn) do
    %{conn | status: 404, resp_body: "The resource for #{path} could not be found."}
  end

  defp format_response(conn) do
    """
    HTTP/1.1 #{conn.status} #{status_reason(conn.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conn.resp_body)}

    #{conn.resp_body}
    """
  end

  defp status_reason(code) do
    case code do
      200 -> "OK"
      404 -> "Not Found"
      403 -> "Forbidden"
      500 -> "Internal server error"
    end
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

    """
  ],
  &Servy.Handler.handle/1
)
