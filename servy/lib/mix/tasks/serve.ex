defmodule Mix.Tasks.Serve do
  @moduledoc """
  `mix serve` starts the Servy.HttpServer on port `4321`\n
  `mix serve 3000` starts the Servy.HttpServer on port `3000`
  """
  @shortdoc "Starts the `Servy.HttpServer` on port `4321` by default"

  use Mix.Task
  @requirements ["app.config"]

  @impl Mix.Task
  def run(args) do
    System.no_halt(true)
    spawn(Servy.HttpServer, :start, [parse_args(args)])
    Mix.shell().info("Server is starting...")
  end

  defp parse_args([]), do: 4321
  defp parse_args([port]), do: String.to_integer(port)
end
