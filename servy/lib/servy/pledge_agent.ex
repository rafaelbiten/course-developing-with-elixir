defmodule Servy.PledgeAgent do
  use Agent

  @this __MODULE__

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, @this)
    initial_state = Keyword.get(opts, :initial_state, [])
    Agent.start_link(fn -> initial_state end, name: name)
  end

  def create(name, amount, this \\ @this) do
    Agent.update(this, fn state -> [{name, amount} | state] end)
  end

  def total_pledged(this \\ @this) do
    Agent.get(this, & &1)
    |> Enum.map(fn {_name, amount} -> amount end)
    |> Enum.sum()
  end

  def recent_pledges(this \\ @this) do
    Agent.get(this, & &1)
  end
end
