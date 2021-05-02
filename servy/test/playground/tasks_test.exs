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

  describe "peek/1" do
    test "peek returns nil for ongoing tasks" do
      pid = Tasks.async(fn -> Tasks.example_task_to_run(200) end)
      assert nil == Tasks.peek(pid)
    end

    test "peek returns task result for completed tasks" do
      pid = Tasks.async(fn -> Tasks.example_task_to_run() end)
      :timer.sleep(20)
      assert {:ok, "result"} == Tasks.peek(pid)
    end

    test "peek returns the expected task result without receiving it" do
      quick_task_pid = Tasks.async(fn -> Tasks.example_task_to_run() end)
      long_task_pid = Tasks.async(fn -> Tasks.example_task_to_run(200) end)

      assert nil == Tasks.peek(quick_task_pid)
      assert nil == Tasks.peek(long_task_pid)
      :timer.sleep(100)
      assert {:ok, "result"} == Tasks.peek(quick_task_pid)
      assert nil == Tasks.peek(long_task_pid)
      :timer.sleep(100)
      assert {:ok, "result"} == Tasks.peek(quick_task_pid)
      assert {:ok, "result"} == Tasks.peek(long_task_pid)
    end
  end
end
