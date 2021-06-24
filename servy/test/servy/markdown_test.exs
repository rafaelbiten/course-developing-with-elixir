defmodule Servy.MarkdownTest do
  use Servy.Case, async: true
  doctest Servy.Markdown
  alias Servy.Markdown

  describe "faq/0" do
    test "returns faq.md as html" do
      faq = Markdown.faq()

      assert remove_whitespace(faq) ==
               ~s{<h1>FrequentlyAskedQuestions</h1><ul><li><p><strong>HaveyoureallyseenBigfoot?</strong></p><p>Yes!Inthis<ahref=\"https://www.youtube.com/watch?v=v77ijOO8oAk\">totallybelievablevideo</a>!</p></li><li><p><strong>No,ImeanseenBigfoot<em>ontherefuge</em>?</strong></p><p>Oh!Notyet,butwe’restilllooking…</p></li><li><p><strong>Canyoujustshowmesomecode?</strong></p><p>Sure!Here’ssomeElixir:</p><pre><codeclass=\"elixir\">[&quot;Bigfoot&quot;,&quot;Yeti&quot;,&quot;Sasquatch&quot;]|&gt;Enum.random()</code></pre></li></ul>}
    end
  end
end
