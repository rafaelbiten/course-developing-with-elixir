defmodule Servy.Count404s do
  @name __MODULE__

  def start(initial_state \\ %{}) do
    {:ok, pid} = Agent.start(fn -> initial_state end)
    Process.register(pid, @name)
    pid
  end

  def count(endpoint) do
    Agent.update(@name, fn state ->
      Map.update(state, endpoint, 1, fn value -> value + 1 end)
    end)
  end

  def get_count(endpoint) do
    Agent.get(@name, & &1)
    |> Map.get(endpoint, 0)
  end

  def get_counts() do
    Agent.get(@name, & &1)
  end
end
