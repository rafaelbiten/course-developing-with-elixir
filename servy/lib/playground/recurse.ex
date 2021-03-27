defmodule Playground.Recurse do
  def sum(list) when is_list(list), do: sum(list, 0)
  def sum([x | xs], total), do: sum(xs, total + x)
  def sum([], total), do: total

  def triple(list) when is_list(list), do: triple(list, [])
  def triple([x | xs], tripled_list), do: triple(xs, [x * 3 | tripled_list])
  def triple([], tripled_list), do: Enum.reverse(tripled_list)
end

1..5
|> Enum.to_list()
|> Playground.Recurse.sum()
|> IO.puts()

1..5
|> Enum.to_list()
|> Playground.Recurse.triple()
|> IO.inspect()
