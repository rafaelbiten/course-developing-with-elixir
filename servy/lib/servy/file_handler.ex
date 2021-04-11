defmodule Servy.FileHandler do
  @moduledoc """
  Module to handle reading files from the file system and returning
  them as the response body. Handles missing files and unexpected error
  """

  def handle_file(conn, %{path: path, file: file}) do
    result =
      Path.join(path, file)
      |> File.read()

    case result do
      {:ok, content} ->
        %{conn | status: 200, resp_body: content}

      {:error, :enoent} ->
        %{conn | status: 404, resp_body: "File '#{path}/#{file}' not found."}

      {:error, error} ->
        reason = List.to_string(:file.format_error(error))
        formatted_error = "Error reading '#{path}': #{reason}"
        %{conn | status: 500, resp_body: formatted_error}
    end
  end
end
