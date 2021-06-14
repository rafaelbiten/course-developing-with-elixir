defmodule Servy.PledgeServerTest do
  use ExUnit.Case
  doctest Servy.PledgeServer
  alias Servy.PledgeServer
  alias Servy.PledgeServer.State

  describe "PledgeServer" do
    @tag :capture_log
    test "processes and does not accumulate unexpected messages" do
      pid = start_supervised!(PledgeServer)

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
      pid = start_supervised!(PledgeServer)

      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    test "can be started without an initial_state" do
      start_supervised!(PledgeServer)
      assert [] == PledgeServer.recent_pledges()
    end

    test "can be started with an initial_state" do
      initial_state = %State{pledges: [{"pledge1", 1}]}
      start_supervised!({PledgeServer, initial_state})

      assert [{"pledge1", 1}] == PledgeServer.recent_pledges()
    end
  end

  describe "create" do
    test "can create new pledges" do
      start_supervised!(PledgeServer)

      PledgeServer.create("pledge1", 1)
      assert [{"pledge1", 1}] == PledgeServer.recent_pledges()

      PledgeServer.create("pledge2", 2)
      assert [{"pledge2", 2}, {"pledge1", 1}] == PledgeServer.recent_pledges()
    end
  end

  describe "total_pledges" do
    test "returns the total amount of pledges" do
      start_supervised!(PledgeServer)

      assert 0 == PledgeServer.total_pledged()

      1..2 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))

      assert 3 == PledgeServer.total_pledged()
    end

    test "respects the cache size" do
      initial_state = %State{cache_size: 2}
      start_supervised!({PledgeServer, initial_state})

      1..3 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))

      assert length(PledgeServer.recent_pledges()) === 2
      assert PledgeServer.recent_pledges() === [{"pledge3", 3}, {"pledge2", 2}]
    end
  end

  describe "set_cache_size" do
    test "can set cache size" do
      initial_state = %State{cache_size: 1}
      start_supervised!({PledgeServer, initial_state})

      1..2 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))

      assert length(PledgeServer.recent_pledges()) === 1
      assert PledgeServer.recent_pledges() === [{"pledge2", 2}]

      PledgeServer.set_cache_size(5)

      1..10 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))

      assert length(PledgeServer.recent_pledges()) === 5
    end
  end

  describe "clear_pledges" do
    test "can clear the list of cached pledges" do
      start_supervised!(PledgeServer)

      1..4 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))

      assert length(PledgeServer.recent_pledges()) == 3
      PledgeServer.clear_pledges()
      assert length(PledgeServer.recent_pledges()) == 0
    end
  end
end
