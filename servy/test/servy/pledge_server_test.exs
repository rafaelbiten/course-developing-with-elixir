defmodule Servy.PledgeServerTest do
  use ExUnit.Case
  doctest Servy.PledgeServer
  alias Servy.PledgeServer

  describe "PledgeServer" do
    @tag :capture_log
    test "processes and does not accumulate unexpected messages" do
      pid = start_supervised!(PledgeServer, [])

      send(pid, {:unexpected, "message"})
      send(pid, {:unexpected, "message"})
      send(pid, {:unexpected, "message"})

      {:messages, messages} = Process.info(pid, :messages)
      assert length(messages) == 3
      assert Enum.member?(messages, {:unexpected, "message"})

      # Not required in this case, but some kind of ping/pong to
      # services can be used as synchronization points to make sure
      # that all messages sent to the service have been processed.
      send(self(), PledgeServer.ping())
      assert_receive :pong

      {:messages, messages} = Process.info(pid, :messages)
      refute Enum.member?(messages, {:unexpected, "message"})
    end
  end

  describe "start" do
    test "starts the process and returns its pid" do
      pid = start_supervised!(PledgeServer, [])

      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "can be started without an initial_state" do
      start_supervised!(PledgeServer)
      assert [] == PledgeServer.recent_pledges()
    end

    test "can be started with an initial_state" do
      initial_state = [{"rafael", 10}]
      start_supervised!({PledgeServer, initial_state})

      assert initial_state == PledgeServer.recent_pledges()
    end
  end

  describe "create" do
    test "can create new pledges" do
      start_supervised!(PledgeServer)

      PledgeServer.create("rafael", 10)
      assert [{"rafael", 10}] == PledgeServer.recent_pledges()

      PledgeServer.create("flavia", 20)
      assert [{"flavia", 20}, {"rafael", 10}] == PledgeServer.recent_pledges()
    end
  end

  describe "total_pledges" do
    test "returns the total amount of pledges" do
      start_supervised!(PledgeServer)

      assert 0 == PledgeServer.total_pledged()

      PledgeServer.create("rafael", 10)
      PledgeServer.create("flavia", 20)
      assert 30 == PledgeServer.total_pledged()
    end
  end

  describe "clear_pledges" do
    test "can clear the list of cached pledges" do
      start_supervised!(PledgeServer)
      PledgeServer.create("rafael", 10)
      PledgeServer.create("flavia", 20)

      assert PledgeServer.recent_pledges() |> length() == 2
      PledgeServer.clear_pledges()
      assert PledgeServer.recent_pledges() |> length() == 0
    end
  end
end
