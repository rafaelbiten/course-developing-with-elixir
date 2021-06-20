defmodule Servy.PledgeServerTest do
  use ExUnit.Case
  doctest Servy.PledgeServer
  alias Servy.PledgeServer
  alias Servy.PledgeServer.State

  describe ":sys" do
    @doc """
    http://erlang.org/doc/man/sys.html

    :sys can be used to check and debug processes

    Leaving some extra tests here as my personal notes
    """

    test "can get the state of a process" do
      pid = start_supervised!({PledgeServer, %State{}})
      assert %{cache_size: 3, pledges: []} = :sys.get_state(pid)

      PledgeServer.set_cache_size(1)
      PledgeServer.create("pledge1", 1)
      assert %{cache_size: 1, pledges: [{"pledge1", 1}]} = :sys.get_state(pid)
    end

    test "can get the full status of a process" do
      pid = start_supervised!({PledgeServer, %State{}})

      assert {:status, pid, {:module, :gen_server},
              [
                [
                  "$initial_call": {Servy.PledgeServer, :init, 1},
                  "$ancestors": [_pid_anc_1, _pid_anc_2]
                ],
                :running,
                pid,
                [],
                [
                  header: 'Status for generic server Elixir.Servy.PledgeServer',
                  data: [{'Status', :running}, {'Parent', pid}, {'Logged events', []}],
                  data: [{'State', %Servy.PledgeServer.State{cache_size: 3, pledges: []}}]
                ]
              ]} = :sys.get_status(pid)
    end

    test "can trace process activities" do
      pid = start_supervised!({PledgeServer, %State{}})
      :sys.trace(pid, true)

      # PledgeServer.set_cache_size(1)
      # PledgeServer.create("pledge1", 1)
    end
  end

  describe "PledgeServer" do
    @tag :capture_log
    test "processes and does not accumulate unexpected messages" do
      pid = start_supervised!({PledgeServer, %State{}})

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
      pid = start_supervised!({PledgeServer, %State{}})

      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    # @tag :skip
    test "can be started without an initial_state" do
      start_supervised!({PledgeServer, nil})
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
      start_supervised!({PledgeServer, %State{}})

      PledgeServer.create("pledge1", 1)
      assert [{"pledge1", 1}] == PledgeServer.recent_pledges()

      PledgeServer.create("pledge2", 2)
      assert [{"pledge2", 2}, {"pledge1", 1}] == PledgeServer.recent_pledges()
    end

    test "respects the limit of cached pledges" do
      pid = start_supervised!({PledgeServer, %State{}})

      1..120 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))
      %State{pledges: pledges} = :sys.get_state(pid)

      assert length(pledges) === 100
      assert hd(pledges) === {"pledge120", 120}
    end
  end

  describe "total_pledges" do
    test "returns the total amount of pledges" do
      start_supervised!({PledgeServer, %State{}})

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

    test "can reset cache size to see more or less of the recent pleges" do
      initial_state = %State{cache_size: 1}
      start_supervised!({PledgeServer, initial_state})

      1..20 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))
      assert length(PledgeServer.recent_pledges()) === 1

      PledgeServer.set_cache_size(15)
      recent_pledges = PledgeServer.recent_pledges()
      assert length(recent_pledges) === 15
      assert hd(recent_pledges) === {"pledge20", 20}
    end

    test "can't be set to a higher value than the cache_limit" do
      pid = start_supervised!({PledgeServer, %State{}})

      assert %State{cache_size: 3} = :sys.get_state(pid)

      PledgeServer.set_cache_size(50)
      assert %State{cache_size: 50} = :sys.get_state(pid)

      PledgeServer.set_cache_size(100)
      assert %State{cache_size: 100} = :sys.get_state(pid)

      PledgeServer.set_cache_size(101)
      assert %State{cache_size: 100} = :sys.get_state(pid)
    end
  end

  describe "clear_pledges" do
    test "can clear the list of cached pledges" do
      start_supervised!({PledgeServer, %State{}})

      1..4 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1))

      assert length(PledgeServer.recent_pledges()) == 3
      PledgeServer.clear_pledges()
      assert length(PledgeServer.recent_pledges()) == 0
    end
  end
end
