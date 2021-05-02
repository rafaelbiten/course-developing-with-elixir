defmodule Playground.TasksTest do
  use ExUnit.Case, async: true
  doctest Playground.Tasks
  alias Playground.Tasks

  test "async takes a function to run and returns a pid - async/1" do
    pid = Tasks.async(&Tasks.example_task_to_run/0)
    assert is_pid(pid), "should return a pid when called"

    receive do
      {^pid, Playground.Tasks, expected} ->
        assert {:ok, "result"} = expected, "received msg for task ^pid should match expected"
    after
      100 -> raise "should receive message for task ^pid"
    end
  end

  test "async can be called as an mfa - async/3" do
    pid = Tasks.async(Playground.Tasks, :example_task_to_run, [])
    assert is_pid(pid), "should return a pid when called"

    receive do
      {^pid, Playground.Tasks, expected} ->
        assert {:ok, "result"} = expected, "received msg for task ^pid should match expected"
    after
      100 -> raise "should receive message for task ^pid"
    end
  end

  test "await takes a task pid and return its result - await/1" do
    pid = Tasks.async(&Tasks.example_task_to_run/0)
    assert {:ok, "result"} = Tasks.await(pid), "should receive result for task ^pid"
  end
end
