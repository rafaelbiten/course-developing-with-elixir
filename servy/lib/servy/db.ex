defmodule Servy.Db do
  @db_path Path.expand("db", File.cwd!())
  @table_bears Path.join(@db_path, "bears.json")

  def all(Servy.Bear) do
    @table_bears
    |> File.read!()
    |> Poison.decode!(as: [%Servy.Bear{}])
  end
end
