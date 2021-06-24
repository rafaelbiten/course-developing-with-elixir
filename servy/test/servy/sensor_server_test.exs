defmodule Servy.SensorServerTest do
  use ExUnit.Case, async: true
  alias Servy.SensorServer
  alias Servy.SensorServer.State

  @name __MODULE__

  @moduletag capture_log: true

  describe "set_refresh_interval" do
    test "can set a new refresh interval" do
      pid = start_supervised!({SensorServer, name: @name})
      %State{} = state = :sys.get_state(pid)
      assert state.refresh_interval === :timer.seconds(5)

      new_refresh_interval = :timer.minutes(60)
      SensorServer.set_refresh_interval(new_refresh_interval, @name)

      %State{} = state = :sys.get_state(pid)
      assert state.refresh_interval === new_refresh_interval
    end

    test "raises for invalid values" do
      start_supervised!({SensorServer, name: @name})

      assert_raise FunctionClauseError, fn ->
        SensorServer.set_refresh_interval("invalid", @name)
      end
    end

    test "raises for intervals lower than the initial one" do
      start_supervised!({SensorServer, name: @name})
      [initial_refresh_interval] = SensorServer.__info__(:attributes)[:initial_refresh_interval]
      SensorServer.set_refresh_interval(initial_refresh_interval, @name)

      assert_raise FunctionClauseError, fn ->
        SensorServer.set_refresh_interval(initial_refresh_interval - 1, @name)
      end
    end
  end
end
