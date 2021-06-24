defmodule Servy.Count404s do
  use Agent

  @this __MODULE__

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, @this)
    initial_state = Keyword.get(opts, :initial_state, %{})
    Agent.start_link(fn -> initial_state end, name: name)
  end

  def count(endpoint, this \\ @this) do
    Agent.update(this, fn state ->
      Map.update(state, endpoint, 1, fn value -> value + 1 end)
    end)
  end

  def get_count(endpoint, this \\ @this) do
    get_counts(this) |> Map.get(endpoint, 0)
  end

  def get_counts(this \\ @this) do
    Agent.get(this, & &1)
  end

  def reset_counts(this \\ @this) do
    Agent.update(this, fn _state -> %{} end)
  end
end
