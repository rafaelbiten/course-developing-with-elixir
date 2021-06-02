defmodule Servy.PledgeAgent do
  use Agent

  @name __MODULE__

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: @name)
  end

  def create(name, amount) do
    Agent.update(@name, fn state -> [{name, amount} | state] end)
  end

  def total_pledged() do
    Agent.get(@name, & &1)
    |> Enum.map(fn {_name, amount} -> amount end)
    |> Enum.sum()
  end

  def recent_pledges() do
    Agent.get(@name, & &1)
  end
end
