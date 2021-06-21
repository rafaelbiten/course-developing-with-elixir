defmodule Servy.PledgeServer do
  @pledge_server __MODULE__

  # alias Playground.GenericServer
  use GenServer
  require Logger

  defmodule State do
    defstruct cache_size: 3, pledges: [], cache_limit: 100
  end

  # client interface

  def start_link(%State{} = initial_state) do
    # GenericServer.start(__MODULE__, initial_state, @pledge_server)
    GenServer.start_link(__MODULE__, initial_state, name: @pledge_server)
  end

  def start_link(_unexpected_initial_state), do: start_link(%State{})

  def create(name, amount) do
    GenServer.call(@pledge_server, {:create, name, amount})
  end

  def recent_pledges() do
    GenServer.call(@pledge_server, :recent_pledges)
  end

  def total_pledged() do
    GenServer.call(@pledge_server, :total_pledged)
  end

  def ping() do
    GenServer.call(@pledge_server, :ping)
  end

  def clear_pledges() do
    GenServer.cast(@pledge_server, :clear_pledges)
  end

  def set_cache_size(cache_size) do
    GenServer.cast(@pledge_server, {:set_cache_size, cache_size})
  end

  # server callbacks

  def init(%State{} = state), do: {:ok, state}
  def init(_invalid_init_state), do: {:ok, fetch_initial_state()}

  defp fetch_initial_state() do
    # we could have async code to initialize the state of this
    %State{}
  end

  def handle_call(:total_pledged, _from, %State{} = state) do
    total_pledged =
      state.pledges
      |> Enum.map(fn {_name, amount} -> amount end)
      |> Enum.sum()

    {:reply, total_pledged, state}
  end

  def handle_call({:create, name, amount}, _from, %State{} = state) do
    new_pledges = [{name, amount} | state.pledges]
    cached_pledges = Enum.take(new_pledges, state.cache_limit)
    {:reply, random_id(), %{state | pledges: cached_pledges}}
  end

  def handle_call(:recent_pledges, _from, %State{} = state) do
    {:reply, Enum.take(state.pledges, state.cache_size), state}
  end

  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  def handle_cast({:set_cache_size, cache_size}, %State{} = state) do
    cache_size =
      if cache_size >= state.cache_limit do
        state.cache_limit
      else
        cache_size
      end

    {:noreply, %{state | cache_size: cache_size}}
  end

  def handle_cast(:clear_pledges, %State{} = state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_info(message, state) do
    Logger.info("Unable to handle message: #{inspect(message)}")
    {:noreply, state}
  end

  defp random_id do
    :rand.uniform(1_000_000)
  end
end
