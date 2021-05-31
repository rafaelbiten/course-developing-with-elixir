defmodule Servy.PledgeAgent do
  @pledge_agent __MODULE__

  def start(initial_state \\ []) do
    {:ok, pid} = Agent.start(fn -> initial_state end)
    Process.register(pid, @pledge_agent)
    pid
  end

  def create(name, amount) do
    Agent.update(@pledge_agent, fn state -> [{name, amount} | state] end)
  end

  def total_pledged() do
    Agent.get(@pledge_agent, & &1)
    |> Enum.map(fn {_name, amount} -> amount end)
    |> Enum.sum()
  end

  def recent_pledges() do
    Agent.get(@pledge_agent, & &1)
  end
end
