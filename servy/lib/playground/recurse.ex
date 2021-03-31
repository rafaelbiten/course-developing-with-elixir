defmodule Playground.Recurse do
  def sum(list) when is_list(list), do: sum(list, 0)
  def sum([x | xs], total), do: sum(xs, total + x)
  def sum([], total), do: total

  def triple(list) when is_list(list), do: triple(list, [])
  def triple([x | xs], tripled_list), do: triple(xs, [x * 3 | tripled_list])
  def triple([], tripled_list), do: Enum.reverse(tripled_list)

  def map([], _f), do: []
  def map(list, f), do: map(list, f, [])
  defp map([x | xs], f, result), do: map(xs, f, [f.(x) | result])
  defp map([], _f, result), do: Enum.reverse(result)
end

1..5
|> Enum.to_list()
|> Playground.Recurse.sum()
|> IO.puts()

1..5
|> Enum.to_list()
|> Playground.Recurse.triple()
|> IO.inspect()

sum = &(&1 + &2)
triple = &(&1 * 3)

1..5
# |> Enum.reduce(fn x, acc -> x + acc end)
# |> Enum.reduce(&(&1 + &2))
|> Enum.reduce(sum)
|> IO.puts()

1..5
# |> Enum.map(fn x -> x * 3 end)
# |> Enum.map(&(&1 * 3))
|> Enum.map(triple)
|> IO.inspect()

1..6
|> Enum.to_list()
|> Playground.Recurse.map(triple)
|> IO.inspect()

Playground.Recurse.map(["hey", "ho"], &"I say #{&1}! ")
|> Enum.join()
|> IO.puts()
