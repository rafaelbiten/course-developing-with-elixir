defmodule Servy.PledgeAgentTest do
  use ExUnit.Case
  alias Servy.PledgeAgent

  test "can create multiple pledges" do
    start_supervised!(PledgeAgent)
    PledgeAgent.create("rafael", 10)
    PledgeAgent.create("flavia", 20)

    assert length(PledgeAgent.recent_pledges()) == 2
  end

  test "can retrieve pledges" do
    start_supervised!(PledgeAgent)
    PledgeAgent.create("rafael", 10)

    assert [{"rafael", 10}] == PledgeAgent.recent_pledges()
  end

  test "can get the total amount of pledges" do
    start_supervised!(PledgeAgent)
    PledgeAgent.create("rafael", 10)
    PledgeAgent.create("flavia", 20)

    assert 30 == PledgeAgent.total_pledged()
  end
end
