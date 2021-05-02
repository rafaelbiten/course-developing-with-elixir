defmodule Playground.Tasks do
  @moduledoc """
  A simplified implementation of how Tasks work internally
  """

  def async(f) when is_function(f) do
    parent = self()
    spawn(fn -> send(parent, {self(), __MODULE__, f.()}) end)
  end

  def await(pid) when is_pid(pid) do
    receive do
      {^pid, __MODULE__, value} -> value
    end
  end
end
