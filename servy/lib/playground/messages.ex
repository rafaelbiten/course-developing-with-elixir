defmodule Playground.Messages do
  @moduledoc false

  # Messages.power_nap(self())
  # receive do {:slept, time} -> IO.puts("Slept for #{time} ms") end
  def power_nap(parent, sleep_up_to_miliseconds \\ 10_000) when is_pid(parent) do
    spawn(fn ->
      time = :rand.uniform(sleep_up_to_miliseconds)
      :timer.sleep(time)
      send(parent, {:slept, time})
    end)
  end
end
