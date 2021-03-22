defmodule Servy.Plugins do
  require Logger

  def track(%{status: status} = conn) do
    case status do
      404 ->
        Logger.warn("Someone tried to reach an invalid route: #{conn.path}")
        conn

      _ ->
        conn
    end
  end

  def rewrite_path(conn) do
    case conn.path do
      "/wildlife" ->
        rewrite_path(conn, "/wildthings")

      _ ->
        conn
    end
  end

  defp rewrite_path(conn, path) do
    Logger.info("Rewriting path from #{conn.path} to #{path}")
    %{conn | path: path}
  end

  def rewrite_query_params(conn) do
    if String.contains?(conn.path, "?id=") do
      [path, id] = String.split(conn.path, "?id=")
      rewrite_path(conn, "#{path}/#{id}")
    else
      conn
    end
  end

  def emojify_resp_body(conn) do
    case conn.status do
      200 -> emojify_resp_body(conn, "😃")
      _ -> conn
    end
  end

  defp emojify_resp_body(conn, emoji) do
    %{conn | resp_body: "#{emoji} #{conn.resp_body} #{emoji}"}
  end
end
