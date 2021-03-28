defmodule Servy.Wildthings do
  alias Servy.Bear

  @spec list_bears() :: [Bear.t()]
  def list_bears do
    [
      %Bear{id: 1, name: "Bear1", type: "Type1", hibernating: true},
      %Bear{id: 2, name: "Bear2", type: "Type2"},
      %Bear{id: 3, name: "Bear3", type: "Type3"},
      %Bear{id: 4, name: "Bear4", type: "Type4"},
      %Bear{id: 5, name: "Bear5", type: "Type5", hibernating: true},
      %Bear{id: 6, name: "Bear6", type: "Type6", hibernating: true},
      %Bear{id: 7, name: "Bear7", type: "Type7"},
      %Bear{id: 8, name: "Bear8", type: "Type8"},
      %Bear{id: 9, name: "Bear9", type: "Type9", hibernating: true},
      %Bear{id: 10, name: "Bear10", type: "Type10", hibernating: true}
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
