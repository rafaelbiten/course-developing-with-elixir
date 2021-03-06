defmodule Servy.PledgeCtrl do
  @moduledoc false

  use Tesla
  plug(Tesla.Middleware.Headers, [{"content-type", "application/json"}])
  plug(Tesla.Middleware.BaseUrl, "https://httparrot.herokuapp.com")

  alias Servy.PledgeAgent
  alias Servy.PledgeView

  def create(conn, %{"name" => name, "amount" => amount}) do
    PledgeAgent.create(name, String.to_integer(amount))

    {:ok, raw_response} =
      Task.async(fn ->
        post(
          "/post",
          Poison.encode!(%{
            event: "Pledge Created",
            name: name,
            amount: amount
          })
        )
      end)
      |> Task.await()

    Poison.decode!(raw_response.body)
    |> Map.get("data")
    |> Poison.decode!()

    %{conn | status: 201, resp_body: "#{name} pledged #{amount}"}
  end

  def index(conn) do
    pledges = PledgeAgent.recent_pledges()
    %{conn | status: 200, resp_body: PledgeView.recent_pledges(pledges)}
  end

  def new(conn) do
    %{conn | status: 200, resp_body: PledgeView.new()}
  end
end
