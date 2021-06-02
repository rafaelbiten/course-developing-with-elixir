defmodule Servy.Count404s do
  use Agent

  @name __MODULE__

  def start_link(initial_value) when is_map(initial_value) do
    Agent.start_link(fn -> initial_value end, name: @name)
  end

  def count(endpoint) do
    Agent.update(@name, fn state ->
      Map.update(state, endpoint, 1, fn value -> value + 1 end)
    end)
  end

  def get_count(endpoint) do
    get_counts()
    |> Map.get(endpoint, 0)
  end

  def get_counts do
    Agent.get(@name, & &1)
  end
end
