defmodule Servy.MixProject do
  use Mix.Project

  def project do
    [
      app: :servy,
      description: "A flawed and limited HTTP server",
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:mix]],
      preferred_cli_env: [
        check: :test,
        check_all: :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    initial_servy_args = []

    # Can be overwritten from the /config files, per environment
    default_env = [port: 3000]

    [
      extra_applications: [:logger, :eex],
      mod: {Servy, initial_servy_args},
      env: default_env
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cortex, "~> 0.6.0", only: [:dev, :test]},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:earmark, "~> 1.4"},
      {:hackney, "~> 1.17.0"},
      {:poison, "~> 4.0"},
      {:tesla, "~> 1.4"}
    ]
  end

  defp aliases do
    [
      check: ["test", "credo --strict"],
      check_all: ["test", "dialyzer", "credo --strict"],
      get: ["deps.get", "deps.compile"]
    ]
  end
end
