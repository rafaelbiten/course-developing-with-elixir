defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  test "greets the world" do
    assert Servy.hello("world") == "Hello, world!"
    refute Servy.hello("there") == :hello
  end
end
