defmodule Playground.Timer do
  def set_reminder(reminder, seconds) do
    spawn(__MODULE__, :remind, [reminder, seconds])
    IO.puts("You'll be reminded to '#{reminder}' in #{seconds} second(s)")
  end

  def remind(reminder, seconds) do
    seconds
    |> :timer.seconds()
    |> :timer.sleep()

    IO.puts(reminder)
  end
end
