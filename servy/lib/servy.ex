defmodule Servy do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Servy.Supervisor.start_link()
  end
end
