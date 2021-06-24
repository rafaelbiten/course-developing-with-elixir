defmodule Servy.PledgeAgentTest do
  use ExUnit.Case, async: true
  alias Servy.PledgeAgent

  @name __MODULE__

  test "can create multiple pledges" do
    start_supervised!({PledgeAgent, name: @name})
    PledgeAgent.create("rafael", 10, @name)
    PledgeAgent.create("flavia", 20, @name)

    assert length(PledgeAgent.recent_pledges(@name)) == 2
  end

  test "can retrieve pledges" do
    start_supervised!({PledgeAgent, name: @name})
    PledgeAgent.create("rafael", 10, @name)

    assert [{"rafael", 10}] == PledgeAgent.recent_pledges(@name)
  end

  test "can get the total amount of pledges" do
    start_supervised!({PledgeAgent, name: @name})
    PledgeAgent.create("rafael", 10, @name)
    PledgeAgent.create("flavia", 20, @name)

    assert 30 == PledgeAgent.total_pledged(@name)
  end
end
