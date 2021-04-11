defmodule Servy.Markdown do
  @moduledoc """
  Working with Markdown docs
  """

  @markdown_path Path.expand("markdown", File.cwd!())

  def faq do
    @markdown_path
    |> Path.join("faq.md")
    |> File.read!()
    |> Earmark.as_html!()
  end
end
