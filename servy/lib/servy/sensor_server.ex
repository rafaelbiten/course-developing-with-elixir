defmodule Servy.SensorServer do
  @moduledoc """
  This server exposes a fn to allow clients to get snapshots.
  These snapshots are cached and refreshed following the refresh_interval.
  """

  use GenServer
  @name __MODULE__

  defmodule State do
    defstruct refresh_interval: :timer.seconds(5),
              snapshots: []
  end

  alias Servy.VideoCam

  # client interface

  def start_link(initial_state \\ %State{}) do
    GenServer.start(__MODULE__, initial_state, name: @name)
  end

  def get_snapshots() do
    GenServer.call(@name, :get_snapshots)
  end

  # server callbacks

  def init(%State{} = state) do
    snapshots = run_tasks_to_get_sensor_data()
    schedule_next_refresh(state.refresh_interval)
    {:ok, %State{state | snapshots: snapshots}}
  end

  def handle_info(:refresh_sensor_data, state) do
    snapshots = run_tasks_to_get_sensor_data()
    schedule_next_refresh(state.refresh_interval)
    {:noreply, %State{state | snapshots: snapshots}}
  end

  def handle_call(:get_snapshots, _from, %State{} = state) do
    {:reply, state.snapshots, state}
  end

  # internal implementation details

  defp schedule_next_refresh(refresh_interval) do
    Process.send_after(self(), :refresh_sensor_data, refresh_interval)
  end

  defp run_tasks_to_get_sensor_data() do
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
