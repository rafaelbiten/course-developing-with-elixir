defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> IO.inspect()
    |> rewrite_query_params
    |> rewrite_path
    |> route
    |> track
    |> emojify_resp_body
    |> format_response
    |> IO.puts()
  end

  # Implementation

  defp parse(request) do
    [method, path, _protocol] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, path: path, resp_body: "", status: nil}
  end

  defp rewrite_path(conn) do
    case conn.path do
      "/wildlife" ->
        rewrite_path(conn, "/wildthings")

      _ ->
        conn
    end
  end

  defp rewrite_path(conn, path) do
    IO.puts("!!! Rewriting path from #{conn.path} to #{path}")
    %{conn | path: path}
  end

  defp rewrite_query_params(conn) do
    if String.contains?(conn.path, "?id=") do
      [path, id] = String.split(conn.path, "?id=")
      rewrite_path(conn, "#{path}/#{id}")
    else
      conn
    end
  end

  defp route(%{method: "GET", path: "/wildthings"} = conn) do
    %{conn | status: 200, resp_body: "Bears, Leões, Tigers"}
  end

  defp route(%{method: "GET", path: "/bears"} = conn) do
    %{conn | status: 200, resp_body: "Teddy, Smokey, Paddington"}
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

  defp track(%{status: status} = conn) do
    case status do
      404 ->
        IO.puts("!!! Someone tried to reach an invalid route: #{conn.path}")
        conn

      _ ->
        conn
    end
  end

  defp emojify_resp_body(conn) do
    case conn.status do
      200 -> emojify_resp_body(conn, "😃")
      _ -> conn
    end
  end

  defp emojify_resp_body(conn, emoji) do
    %{conn | resp_body: "#{emoji} #{conn.resp_body} #{emoji}"}
  end

  defp status_reason(code) do
    case code do
      200 -> "OK"
      404 -> "Not Found"
      403 -> "Forbidden"
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

    """
  ],
  &Servy.Handler.handle/1
)
