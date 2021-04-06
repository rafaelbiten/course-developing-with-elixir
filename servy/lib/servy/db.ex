defmodule Servy.Db do
  @db_path Path.expand("db", File.cwd!())
  @bears Path.join(@db_path, "bears.json")

  def all(Servy.Bear) do
    read_file(@bears, &Poison.decode!(&1, as: [%Servy.Bear{}]))
  end

  defp read_file(table, decode_fn) do
    case File.read(table) do
      {:ok, entities} ->
        decode_fn.(entities)

      {:error, reason} ->
        IO.inspect("Can't read #{table}: #{reason}")
        []
    end
  end
end
