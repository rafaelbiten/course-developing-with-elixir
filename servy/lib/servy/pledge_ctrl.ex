defmodule Servy.PledgeCtrl do
  alias Servy.PledgeServer

  def create(conn, %{"name" => name, "amount" => amount}) do
    PledgeServer.create(name, String.to_integer(amount))
    %{conn | status: 201, resp_body: "#{name} pledged #{amount}"}
  end

  def index(conn) do
    pledges = PledgeServer.recent_pledges()
    %{conn | status: 200, resp_body: inspect(pledges)}
  end
end
