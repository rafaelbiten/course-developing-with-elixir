defmodule Playground.TasksTest do
  use ExUnit.Case, async: true
  doctest Playground.Tasks
  alias Playground.Tasks

  describe "async/1" do
    test "async takes a function to run and returns a pid" do
      pid = Tasks.async(&Tasks.example_task_to_run/0)
      assert is_pid(pid), "should return a pid when called"

      receive do
        {^pid, Playground.Tasks, expected} ->
          assert {:ok, "result"} = expected, "received msg for task ^pid should match expected"
      after
        50 -> raise "should receive message for task ^pid"
      end
    end
  end

  describe "async/3" do
    test "async can be called with an MFA" do
      pid = Tasks.async(Playground.Tasks, :example_task_to_run, [])
      assert is_pid(pid), "should return a pid when called"

      receive do
        {^pid, Playground.Tasks, expected} ->
          assert {:ok, "result"} = expected, "received msg for task ^pid should match expected"
      after
        50 -> raise "should receive message for task ^pid"
      end
    end
  end

  describe "await/1" do
    test "await takes a task pid and return its result" do
      pid = Tasks.async(&Tasks.example_task_to_run/0)
      assert {:ok, "result"} = Tasks.await(pid), "should receive result for task ^pid"
    end

    test "await exits when task takes too long" do
      pid = Tasks.async(fn -> Tasks.example_task_to_run(200) end)
      assert catch_exit(Tasks.await(pid) == "time out")
    end

    test "await takes an optional second argument to set timeout" do
      pid = Tasks.async(fn -> Tasks.example_task_to_run(200) end)
      assert {:ok, "result"} = Tasks.await(pid, :infinity), "should wait for the task to finish"
    end
  end
end
