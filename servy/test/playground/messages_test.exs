defmodule Playground.MessagesTest do
  use ExUnit.Case
  doctest Playground.Messages
  alias Playground.Messages

  describe "power_nap" do
    test "sleeps for 0 to 10 seconds and notifies time slept" do
      {:messages, []} = Process.info(self(), :messages)
      Messages.power_nap(self(), 1)
      assert_receive({:slept, time_slept})
      assert time_slept == 1
    end
  end
end
