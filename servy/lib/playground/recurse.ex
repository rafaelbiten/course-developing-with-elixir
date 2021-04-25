defmodule Playground.Recurse do
  @moduledoc """
  Working with lists and recursion
  """

  def reduce([h | t], acc, f), do: reduce(t, f.(h, acc), f)
  def reduce([], acc, _f), do: acc

  # def map([h | t], f), do: [f.(h) | map(t, f)]
  # def map([], _f), do: []

  # map in terms of reduce
  def map(list, f) do
    reduce(list, [], fn x, acc -> [f.(x) | acc] end)
    |> :lists.reverse()
  end

  def filter(list, predicate_f) do
    reduce(list, [], fn x, acc ->
      case predicate_f.(x) do
        true -> [x | acc]
        _ -> acc
      end
    end)
    |> :lists.reverse()
  end

  def sum(list, initial \\ 0), do: reduce(list, initial, &(&1 + &2))
  def triple(list), do: map(list, &(&1 * 3))

  # predicate functions
  def is_odd?(n), do: :math.fmod(n, 2) != 0
  def is_even?(n), do: :math.fmod(n, 2) == 0
end
