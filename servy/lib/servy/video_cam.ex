defmodule Servy.VideoCam do
  def get_snapshot(camera_name) do
    # simulate that the api can be slow
    :timer.sleep(:timer.seconds(1))

    "#{camera_name}-snapshot.jpg"
  end
end
