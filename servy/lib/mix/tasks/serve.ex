defmodule Mix.Tasks.Serve do
  @moduledoc """
  `mix serve` starts the Servy.HttpServer on port `4000`\n
  `mix serve 3000` starts the Servy.HttpServer on port `3000`
  """
  @shortdoc "Starts the `Servy.HttpServer` on port `4000` by default"

  use Mix.Task
  @requirements ["app.config"]

  @impl Mix.Task
  def run(args) do
    parse_args(args)
    |> Servy.HttpServer.start()
  end

  defp parse_args([]), do: 4000
  defp parse_args([port]), do: String.to_integer(port)
end