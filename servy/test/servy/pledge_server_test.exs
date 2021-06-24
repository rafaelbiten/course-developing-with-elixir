defmodule Servy.PledgeServerTest do
  use ExUnit.Case, async: true
  doctest Servy.PledgeServer
  alias Servy.PledgeServer
  alias Servy.PledgeServer.State

  @name __MODULE__

  describe ":sys" do
    @doc """
    http://erlang.org/doc/man/sys.html

    :sys can be used to check and debug processes

    Leaving some extra tests here as my personal notes
    """

    test "can get the state of a process" do
      pid = start_supervised!({PledgeServer, name: @name})
      assert %{cache_size: 3, pledges: []} = :sys.get_state(pid)

      PledgeServer.set_cache_size(1, @name)
      PledgeServer.create("pledge1", 1, @name)
      assert %{cache_size: 1, pledges: [{"pledge1", 1}]} = :sys.get_state(pid)
    end

    test "can get the full status of a process" do
      pid = start_supervised!({PledgeServer, name: @name})
      assert {:status, ^pid, {:module, :gen_server}, _full_status} = :sys.get_status(pid)
    end

    test "can trace process activities" do
      pid = start_supervised!({PledgeServer, name: @name})
      :sys.trace(pid, true)

      # PledgeServer.set_cache_size(1)
      # PledgeServer.create("pledge1", 1)
    end
  end

  describe "PledgeServer" do
    @tag :capture_log
    test "processes and does not accumulate unexpected messages" do
      pid = start_supervised!({PledgeServer, name: @name})

      send(pid, {:unexpected, "message"})
      send(pid, {:unexpected, "message"})
      send(pid, {:unexpected, "message"})

      {:messages, messages} = Process.info(pid, :messages)
      assert length(messages) == 3
      assert Enum.member?(messages, {:unexpected, "message"})

      # Not required in this case, but some kind of ping/pong to
      # services can be used as synchronization points to make sure
      # that all messages sent to the service have been processed.
      send(self(), PledgeServer.ping(@name))
      assert_receive :pong

      {:messages, messages} = Process.info(pid, :messages)
      refute Enum.member?(messages, {:unexpected, "message"})
    end
  end

  describe "start" do
    test "starts the process and returns its pid" do
      pid = start_supervised!({PledgeServer, name: @name})

      assert is_pid(pid)
      assert Process.alive?(pid)
    end

    # @tag :skip
    test "can be started without an initial_state" do
      start_supervised!({PledgeServer, name: @name})
      assert [] == PledgeServer.recent_pledges(@name)
    end

    test "can be started with an initial_state" do
      initial_state = %State{pledges: [{"pledge1", 1}]}
      start_supervised!({PledgeServer, name: @name, initial_state: initial_state})
      assert [{"pledge1", 1}] == PledgeServer.recent_pledges(@name)
    end
  end

  describe "create" do
    test "can create new pledges" do
      start_supervised!({PledgeServer, name: @name})

      PledgeServer.create("pledge1", 1, @name)
      assert [{"pledge1", 1}] == PledgeServer.recent_pledges(@name)

      PledgeServer.create("pledge2", 2, @name)
      assert [{"pledge2", 2}, {"pledge1", 1}] == PledgeServer.recent_pledges(@name)
    end

    test "respects the limit of cached pledges" do
      pid = start_supervised!({PledgeServer, name: @name})

      1..120 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1, @name))
      %State{pledges: pledges} = :sys.get_state(pid)

      assert length(pledges) === 100
      assert hd(pledges) === {"pledge120", 120}
    end
  end

  describe "total_pledges" do
    test "returns the total amount of pledges" do
      start_supervised!({PledgeServer, name: @name})

      assert 0 == PledgeServer.total_pledged(@name)
      1..2 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1, @name))
      assert 3 == PledgeServer.total_pledged(@name)
    end

    test "respects the cache size" do
      initial_state = %State{cache_size: 2}
      start_supervised!({PledgeServer, name: @name, initial_state: initial_state})

      1..3 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1, @name))

      assert 2 == length(PledgeServer.recent_pledges(@name))
      assert [{"pledge3", 3}, {"pledge2", 2}] == PledgeServer.recent_pledges(@name)
    end
  end

  describe "set_cache_size" do
    test "can set cache size" do
      initial_state = %State{cache_size: 1}
      start_supervised!({PledgeServer, name: @name, initial_state: initial_state})

      1..2 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1, @name))

      assert 1 == length(PledgeServer.recent_pledges(@name))
      assert [{"pledge2", 2}] == PledgeServer.recent_pledges(@name)

      PledgeServer.set_cache_size(5, @name)

      1..10 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1, @name))

      assert 5 == length(PledgeServer.recent_pledges(@name))
    end

    test "can reset cache size to see more or less of the recent pleges" do
      initial_state = %State{cache_size: 1}
      start_supervised!({PledgeServer, name: @name, initial_state: initial_state})

      1..20 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1, @name))
      assert 1 == length(PledgeServer.recent_pledges(@name))

      PledgeServer.set_cache_size(15, @name)
      recent_pledges = PledgeServer.recent_pledges(@name)
      assert length(recent_pledges) === 15
      assert hd(recent_pledges) === {"pledge20", 20}
    end

    test "can't be set to a higher value than the cache_limit" do
      pid = start_supervised!({PledgeServer, name: @name})

      assert %State{cache_size: 3} = :sys.get_state(pid)

      PledgeServer.set_cache_size(50, @name)
      assert %State{cache_size: 50} = :sys.get_state(pid)

      PledgeServer.set_cache_size(100, @name)
      assert %State{cache_size: 100} = :sys.get_state(pid)

      PledgeServer.set_cache_size(101, @name)
      assert %State{cache_size: 100} = :sys.get_state(pid)
    end
  end

  describe "clear_pledges" do
    test "can clear the list of cached pledges" do
      start_supervised!({PledgeServer, name: @name})

      1..4 |> Enum.each(&PledgeServer.create("pledge#{&1}", &1, @name))

      assert 3 == length(PledgeServer.recent_pledges(@name))
      PledgeServer.clear_pledges(@name)
      assert 0 == length(PledgeServer.recent_pledges(@name))
    end
  end
end
