defmodule Playground.RecurseTest do
  use ExUnit.Case, async: true
  doctest Playground.Recurse
  alias Playground.Recurse

  @numbers [1, 2, 3, 4, 5]
  @strings ["a", "b", "c", "d", "e"]

  describe "reduce" do
    test "can reduce a list of numbers" do
      assert Recurse.reduce(@numbers, 0, &(&1 + &2)) == 15
    end

    test "can reduce a list of numbers with initial value" do
      assert Recurse.reduce(@numbers, 10, &(&1 + &2)) == 25
    end

    test "can reduce a list of strings" do
      assert Recurse.reduce(@strings, "", &(&2 <> &1)) == "abcde"
    end

    test "can reduce a list of strings with initial value" do
      assert Recurse.reduce(@strings, "123", &(&2 <> &1)) == "123abcde"
    end

    test "handles empty list by returning initial value" do
      assert Recurse.reduce([], "initial", &(&2 <> &1)) == "initial"
    end
  end

  describe "map" do
    test "can map each value of a list into a new value" do
      assert Recurse.map(@numbers, &(&1 * 2)) == [2, 4, 6, 8, 10]
    end

    test "handles empty list by returning empty list" do
      assert Recurse.map([], & &1) == []
    end
  end

  describe "filter" do
    test "uses predicate function to filter items" do
      assert Recurse.filter(@numbers, &Recurse.is_odd?/1) == [1, 3, 5]
      assert Recurse.filter(@numbers, &Recurse.is_even?/1) == [2, 4]
    end

    test "handles empty list by returning empty list" do
      assert Recurse.filter([], & &1) == []
    end
  end

  describe "is_odd?" do
    test "returns true for odd numbers only" do
      assert Recurse.is_odd?(1) == true
      refute Recurse.is_odd?(2) == true
    end
  end
end
