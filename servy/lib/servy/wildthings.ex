defmodule Servy.Wildthings do
  alias Servy.Bear

  @spec list_bears() :: [Bear.t()]
  def list_bears do
    [
      %Bear{id: 1, name: "Teddy", type: "Brown", hibernating: true},
      %Bear{id: 2, name: "Smokey", type: "Black"},
      %Bear{id: 3, name: "Paddington", type: "Brown"},
      %Bear{id: 4, name: "Scarface", type: "Grizzly", hibernating: true},
      %Bear{id: 5, name: "Snow", type: "Polar"},
      %Bear{id: 6, name: "Brutus", type: "Grizzly"},
      %Bear{id: 7, name: "Rosie", type: "Black", hibernating: true},
      %Bear{id: 8, name: "Roscoe", type: "Panda"},
      %Bear{id: 9, name: "Iceman", type: "Polar", hibernating: true},
      %Bear{id: 10, name: "Kenai", type: "Grizzly"}
    ]
  end

  @spec get_bear(term()) :: Bear.t() | nil
  def get_bear(id) do
    byId = fn x ->
      if is_integer(id),
        do: id == x.id,
        else: id == Integer.to_string(x.id)
    end

    list_bears() |> Enum.find(byId)
  end
end
