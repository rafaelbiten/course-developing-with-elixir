defmodule Servy.Count404s do
  use Agent

  @name __MODULE__

  def start_link(opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:name, @name)
      |> Keyword.put_new(:initial_state, %{})

    Agent.start_link(fn -> Keyword.fetch!(opts, :initial_state) end, opts)
  end

  def count(endpoint, name \\ @name) do
    Agent.update(name, fn state ->
      Map.update(state, endpoint, 1, fn value -> value + 1 end)
    end)
  end

  def get_count(endpoint, name \\ @name) do
    get_counts(name) |> Map.get(endpoint, 0)
  end

  def get_counts(name \\ @name) do
    Agent.get(name, & &1)
  end

  def reset_counts(name \\ @name) do
    Agent.update(name, fn _state -> %{} end)
  end
end
