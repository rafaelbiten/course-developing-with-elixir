defmodule Servy.BearView do
  require EEx

  @templates_path Path.expand("templates", File.cwd!())

  @doc """
  `EEx.function_from_file` macro precompiles templates into new functions and is favored
  over `EEx.eval_file` that would read and parse the same template each time it gets called.
  """

  EEx.function_from_file(:def, :index, Path.join(@templates_path, "index.eex"), [:bears])
  EEx.function_from_file(:def, :show, Path.join(@templates_path, "show.eex"), [:bear])
end
