defmodule Servy.DbTest do
  use ExUnit.Case
  doctest Servy.Db
  alias Servy.Db

  test "fetching all bears" do
    bears = Db.all(Servy.Bear)
    assert Enum.all?(bears, &is_struct(&1, Servy.Bear))
  end
end
