alias Tesla, as: Client
alias Servy.HttpServer, as: Server

alias Playground.Timer
alias Playground.Recurse
alias Playground.Messages

alias Servy.{ PledgeServer, PledgeCtrl }

if (Application.get_env(:servy, :environment) == :dev) do
  Servy.ServicesSupervisor.start_link()
end
