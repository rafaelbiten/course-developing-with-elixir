defmodule Playground.Comprehensions do
  @ranks ["A", "2", "3", "J", "Q", "K"]
  @suits ["♦️", "♠️", "♥️", "♣️"]

  def deal_hand() do
    for rank <- @ranks, suit <- @suits, do: rank <> suit
  end
end

list = Enum.to_list(1..3)

IO.puts("Normal map")
Enum.map(list, &IO.puts/1)

IO.puts("List comprehension")
for x <- list, do: IO.puts(x)

# ---------------------------------------

style = %{"width" => 10, "height" => 20}

IO.puts("Normal map")

_ =
  Map.new(style, fn {key, value} -> {String.to_atom(key), value} end)
  |> IO.inspect()

IO.puts("List comprehension, pushing result 'into' another Collectable")

_ =
  for({key, value} <- style, into: %{}, do: {String.to_atom(key), value})
  |> IO.inspect()

# ---------------------------------------

Playground.Comprehensions.deal_hand() |> IO.inspect()
