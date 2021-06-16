defmodule Servy.SensorServerTest do
  use ExUnit.Case
  alias Servy.SensorServer
  alias Servy.SensorServer.State

  describe "set_refresh_interval" do
    test "can set a new refresh interval" do
      pid = start_supervised!(SensorServer)
      %State{} = state = :sys.get_state(pid)
      assert state.refresh_interval === :timer.seconds(5)

      new_refresh_interval = :timer.minutes(60)
      SensorServer.set_refresh_interval(new_refresh_interval)

      %State{} = state = :sys.get_state(pid)
      assert state.refresh_interval === new_refresh_interval
    end

    test "raises for invalid values" do
      start_supervised!(SensorServer)

      assert_raise FunctionClauseError, fn ->
        SensorServer.set_refresh_interval("invalid")
      end
    end

    test "raises for intervals lower than the initial one" do
      start_supervised!(SensorServer)
      [initial_refresh_interval] = SensorServer.__info__(:attributes)[:initial_refresh_interval]
      SensorServer.set_refresh_interval(initial_refresh_interval)

      assert_raise FunctionClauseError, fn ->
        SensorServer.set_refresh_interval(initial_refresh_interval - 1)
      end
    end
  end
end
