defmodule Servy.PledgeCtrl do
  alias Servy.PledgeAgent

  def create(conn, %{"name" => name, "amount" => amount}) do
    PledgeAgent.create(name, String.to_integer(amount))
    %{conn | status: 201, resp_body: "#{name} pledged #{amount}"}
  end

  def index(conn) do
    pledges = PledgeAgent.recent_pledges()
    %{conn | status: 200, resp_body: inspect(pledges)}
  end
end
