defmodule Servy.Wildthings do
  @moduledoc """
  Wildthings data access layer
  """

  alias Servy.Bear
  alias Servy.Db

  @spec list_bears() :: [Bear.t()]
  def list_bears, do: Db.all(Servy.Bear)

  @spec get_bear(term()) :: Bear.t() | nil
  def get_bear(id) do
    by_id = fn x ->
      if is_integer(id),
        do: id == x.id,
        else: id == Integer.to_string(x.id)
    end

    list_bears() |> Enum.find(by_id)
  end
end
