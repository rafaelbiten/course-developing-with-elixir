ExUnit.start()

defmodule Servy.Case do
  @moduledoc """
  Test modules can use Servy.Case instead of ExUnit.Case
  And gain access to the functions we have in this module
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Servy.Case
    end
  end

  def contains(content, pattern) do
    case String.contains?(content, pattern) do
      true -> content
      false -> raise "Content does not contain pattern: #{pattern}"
    end
  end

  def remove_whitespace(string) do
    String.replace(string, ~r{\s}, "")
  end

  def reset_404_count(_context) do
    Servy.Count404s.reset_counts()
    :ok
  end
end
