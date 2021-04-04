defmodule Playground.Comprehensions do
  @ranks ["A", "2", "3", "J", "Q", "K"]
  @suits ["♦️", "♠️", "♥️", "♣️"]

  def new_deck_of_cards() do
    for rank <- @ranks, suit <- @suits, do: rank <> suit
  end

  def shuffle_deck(deck) do
    Enum.shuffle(deck)
  end

  def deal_hand(deck, hand_size) do
    Enum.split(deck, hand_size)
  end

  def deal_hand(deck, hand_size, players) do
    {hands, remaining_cards} =
      deck
      |> Enum.chunk_every(hand_size)
      |> Enum.split(players)

    {hands, Enum.flat_map(remaining_cards, & &1)}
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

{_3_cards_hand, _cards} =
  Playground.Comprehensions.new_deck_of_cards()
  |> Playground.Comprehensions.shuffle_deck()
  |> Playground.Comprehensions.deal_hand(3)
  |> IO.inspect(label: "👉 New hand, shuffle and deal 3 cards:\n")

{[_p1_hand, _p2_hand], _cards} =
  Playground.Comprehensions.new_deck_of_cards()
  |> Playground.Comprehensions.shuffle_deck()
  |> Playground.Comprehensions.deal_hand(3, 2)
  |> IO.inspect(label: "👉 New hand, suffle and deal 3 cards for 2 players:\n")
