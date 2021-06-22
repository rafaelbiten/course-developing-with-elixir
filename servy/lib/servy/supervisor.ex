defmodule Servy.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Each children gets called with its child_spec fn (with [] keyword as default arg)
  child_spec internally calls start_link on the module, passing the arg

  some good examples at: https://online.pragmaticstudio.com/courses/elixir/steps/64
  """
  def init(:ok) do
    children = [
      Servy.HttpServerGenServer,
      Servy.ServicesSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
