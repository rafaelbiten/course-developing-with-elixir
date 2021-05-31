defmodule Servy.PledgeServerTest do
  use ExUnit.Case
  doctest Servy.PledgeServer
  alias Servy.PledgeServer

  describe "PledgeServer" do
    test "processes and does not accumulate unexpected messages" do
      pid = PledgeServer.start()
      Process.link(pid)

      send(pid, {:unexpected, "message"})
      send(pid, {:unexpected, "message"})
      send(pid, {:unexpected, "message"})

      {:messages, messages} = Process.info(pid, :messages)
      assert length(messages) == 3

      # give time for the mailbox to process the unexpected messages
      # there's probably a better way to do this
      :timer.sleep(1)

      {:messages, messages} = Process.info(pid, :messages)
      assert [] == messages
      assert length(messages) == 0
    end
  end

  describe "start" do
    test "starts the process and returns its pid" do
      pid = PledgeServer.start()
      Process.link(pid)

      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "can be started without an initial_state" do
      PledgeServer.start() |> Process.link()
      assert [] == PledgeServer.recent_pledges()
    end

    test "can be started with an initial_state" do
      initial_state = [{"rafael", 10}]
      PledgeServer.start(initial_state) |> Process.link()

      assert initial_state == PledgeServer.recent_pledges()
    end
  end

  describe "create" do
    test "can create new pledges" do
      PledgeServer.start() |> Process.link()

      PledgeServer.create("rafael", 10)
      assert [{"rafael", 10}] == PledgeServer.recent_pledges()

      PledgeServer.create("flavia", 20)
      assert [{"flavia", 20}, {"rafael", 10}] == PledgeServer.recent_pledges()
    end
  end

  describe "total_pledges" do
    test "returns the total amount of pledges" do
      PledgeServer.start() |> Process.link()

      assert 0 == PledgeServer.total_pledged()

      PledgeServer.create("rafael", 10)
      PledgeServer.create("flavia", 20)
      assert 30 == PledgeServer.total_pledged()
    end
  end
end
