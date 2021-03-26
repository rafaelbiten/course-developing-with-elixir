defmodule Recurse do
  def sum(list) when is_list(list), do: sum(list, 0)

  def sum([], total), do: total
  def sum([x | xs], total), do: sum(xs, total + x)
end

1..5
|> Enum.to_list()
|> Recurse.sum()
|> IO.inspect()
