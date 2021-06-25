defmodule Servy.SensorServer do
  @moduledoc """
  This server exposes a fn to allow clients to get snapshots.
  These snapshots are cached and refreshed following the refresh_interval.
  """

  use GenServer
  require Logger

  @this __MODULE__

  # setting persist: true because we're accessing this module attribute from tests
  # another option would be to expose a fn that returns the value of the attribute
  # but leaving this in here for future reference on how to do it
  Module.register_attribute(@this, :initial_refresh_interval, persist: true)
  @initial_refresh_interval :timer.seconds(5)

  defmodule State do
    @moduledoc false

    alias Servy.SensorServer

    defstruct refresh_interval: Module.get_attribute(SensorServer, :initial_refresh_interval),
              snapshots: []
  end

  alias Servy.VideoCam

  # client interface

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, @this)
    initial_state = Keyword.get(opts, :initial_state, %State{})
    Logger.info("Starting Sensor Server with: #{inspect(initial_state)}")
    GenServer.start_link(__MODULE__, initial_state, name: name)
  end

  def get_snapshots(this \\ @this) do
    GenServer.call(this, :get_snapshots)
  end

  def set_refresh_interval(refresh_interval, this \\ @this)
      when is_integer(refresh_interval) and refresh_interval >= @initial_refresh_interval do
    GenServer.cast(this, {:set_refresh_interval, refresh_interval})
  end

  # server callbacks

  def init(%State{} = state) do
    snapshots = run_tasks_to_get_sensor_data()
    schedule_next_refresh(state.refresh_interval)
    {:ok, %State{state | snapshots: snapshots}}
  end

  def init(_), do: {:ok, %State{}}

  def handle_info(:refresh_sensor_data, state) do
    snapshots = run_tasks_to_get_sensor_data()
    schedule_next_refresh(state.refresh_interval)
    {:noreply, %State{state | snapshots: snapshots}}
  end

  def handle_info(unexpected, state) do
    Logger.warn("#{@this} received unexpected info: #{inspect(unexpected)}")
    {:noreply, state}
  end

  def handle_call(:get_snapshots, _from, %State{} = state) do
    {:reply, state.snapshots, state}
  end

  def handle_cast({:set_refresh_interval, refresh_interval}, %State{} = state) do
    {:noreply, %State{state | refresh_interval: refresh_interval}}
  end

  # internal implementation details

  defp schedule_next_refresh(refresh_interval) do
    Process.send_after(self(), :refresh_sensor_data, refresh_interval)
  end

  defp run_tasks_to_get_sensor_data do
    0..3
    |> Enum.map(fn _ -> time_based_random_id() end)
    |> Enum.map(&Task.async(VideoCam, :get_snapshot, ["cam-#{&1}"]))
    |> Enum.map(&Task.await/1)
  end

  defp time_based_random_id do
    Time.utc_now()
    |> Time.to_string()
    |> String.split(".")
    |> Enum.at(1)
  end
end
