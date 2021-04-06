defmodule Servy.Plugins do
  require Logger
  alias Servy.Conn

  def track(%Conn{status: status} = conn) do
    case status do
      404 ->
        Logger.warn("Someone tried to reach an invalid route: #{conn.path}")
        conn

      _ ->
        conn
    end
  end

  def rewrite_path(%Conn{} = conn) do
    case conn.path do
      "/wildlife" ->
        rewrite_path(conn, "/wildthings")

      _ ->
        conn
    end
  end

  defp rewrite_path(%Conn{} = conn, path) do
    Logger.info("Rewriting path from #{conn.path} to #{path}")
    %{conn | path: path}
  end

  def rewrite_query_params(%Conn{} = conn) do
    if String.contains?(conn.path, "?id=") do
      [path, id] = String.split(conn.path, "?id=")
      rewrite_path(conn, "#{path}/#{id}")
    else
      conn
    end
  end

  def emojify_resp_body(%Conn{} = conn) do
    case conn.status do
      200 -> emojify_resp_body(conn, "😃")
      _ -> conn
    end
  end

  defp emojify_resp_body(%Conn{} = conn, emoji) do
    case conn.resp_content_type do
      "text/html" -> %{conn | resp_body: "#{emoji} #{conn.resp_body} #{emoji}"}
      _ -> conn
    end
  end
end
