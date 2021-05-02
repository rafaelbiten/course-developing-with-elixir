defmodule Playground.TasksTest do
  use ExUnit.Case, async: true
  doctest Playground.Tasks
  alias Playground.Tasks

  test "async" do
    pid =
      Tasks.async(fn ->
        :timer.sleep(10)
        {:ok, "result"}
      end)

    assert is_pid(pid), "should return a pid when called"

    receive do
      {^pid, Playground.Tasks, expected} ->
        assert {:ok, "result"} = expected, "received msg for task ^pid should match expected"
    after
      100 -> raise "should receive message for task ^pid"
    end
  end

  test "await" do
    pid =
      Tasks.async(fn ->
        :timer.sleep(10)
        {:ok, "result"}
      end)

    assert {:ok, "result"} = Tasks.await(pid), "should receive result for task ^pid"
  end
end
