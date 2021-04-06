defmodule Servy.Wildthings do
  alias Servy.Db
  alias Servy.Bear

  @spec list_bears() :: [Bear.t()]
  def list_bears, do: Db.all(Servy.Bear)

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
