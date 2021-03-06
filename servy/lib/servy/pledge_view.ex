defmodule Servy.PledgeView do
  require EEx

  @templates_path Path.expand("templates", File.cwd!())

  EEx.function_from_file(:def, :new, Path.join(@templates_path, "pledge_new.html"), [])

  EEx.function_from_file(
    :def,
    :recent_pledges,
    Path.join(@templates_path, "pledges_recent.html.eex"),
    [:pledges]
  )
end
