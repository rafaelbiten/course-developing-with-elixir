ExUnit.start()

defmodule TestHelper do
  def contains(content, pattern) do
    case String.contains?(content, pattern) do
      true -> content
      false -> raise "Content does not contain pattern: #{pattern}"
    end
  end

  def remove_whitespace(string) do
    String.replace(string, ~r{\s}, "")
  end
end
