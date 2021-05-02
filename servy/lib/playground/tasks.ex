defmodule Playground.Tasks do
  @moduledoc """
  A simplified implementation of how Tasks work internally
  """

  def async(f) when is_function(f) do
    parent = self()
    spawn(fn -> send(parent, {self(), __MODULE__, f.()}) end)
  end

  def async(m, f, a) when is_atom(m) when is_atom(f) when is_list(a) do
    async(fn -> apply(m, f, a) end)
  end

  def await(pid, timeout \\ 100) when is_pid(pid) do
    receive do
      {^pid, __MODULE__, value} -> value
    after
      timeout -> exit("time out")
    end
  end

  def example_task_to_run(sleep_amount \\ 10) do
    :timer.sleep(sleep_amount)
    {:ok, "result"}
  end
end
