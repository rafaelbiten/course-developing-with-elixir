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

  def peek(pid) do
    empty_message = {self(), __MODULE__, nil}
    {:messages, messages} = Process.info(self(), :messages)

    # returns the last element of the message
    # either `nil` from empty message or value from resolved task
    messages
    |> Enum.find(empty_message, fn {msg_pid, _, _} -> msg_pid == pid end)
    |> elem(2)
  end

  def example_task_to_run(sleep_amount \\ 10) do
    :timer.sleep(sleep_amount)
    {:ok, "result"}
  end
end
