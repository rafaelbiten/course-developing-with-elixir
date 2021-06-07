alias Tesla, as: Client
alias Servy.HttpServer, as: Server

alias Playground.Timer
alias Playground.Recurse
alias Playground.Messages

alias Servy.{ PledgeServer, PledgeCtrl }

if (Application.get_env(:servy, :environment) == :dev) do
  Servy.Count404s.start_link(%{})
  Servy.PledgeAgent.start_link([])
  spawn(Servy.HttpServer, :start, [4000]) |> Process.link()
end
