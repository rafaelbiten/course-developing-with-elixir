defmodule Servy.Count404sTest do
  use ExUnit.Case, async: true
  doctest Servy.Count404s
  alias Servy.Count404s

  @name __MODULE__

  test "reports counts of missing path requests" do
    start_supervised!({Count404s, name: @name})

    Count404s.count("/bigfoot", @name)
    Count404s.count("/nessie", @name)
    Count404s.count("/nessie", @name)
    Count404s.count("/bigfoot", @name)
    Count404s.count("/nessie", @name)

    assert Count404s.get_count("/nessie", @name) == 3
    assert Count404s.get_count("/bigfoot", @name) == 2

    assert Count404s.get_counts(@name) == %{"/bigfoot" => 2, "/nessie" => 3}
  end

  test "can reset counts" do
    start_supervised!({Count404s, name: @name})

    Count404s.count("/nessie", @name)
    Count404s.count("/nessie", @name)

    assert Count404s.get_counts(@name) == %{"/nessie" => 2}

    Count404s.reset_counts(@name)
    assert Count404s.get_counts(@name) == %{}
  end

  test "can take an initial state" do
    initial_state = %{"/initial" => 2}

    start_supervised!({Count404s, name: @name, initial_state: initial_state})
    assert initial_state == Count404s.get_counts(@name)
  end
end
