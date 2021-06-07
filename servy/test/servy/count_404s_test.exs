defmodule Servy.Count404sTest do
  use ExUnit.Case
  doctest Servy.Count404s
  alias Servy.Count404s

  test "reports counts of missing path requests" do
    start_supervised!({Count404s, %{}})

    Count404s.count("/bigfoot")
    Count404s.count("/nessie")
    Count404s.count("/nessie")
    Count404s.count("/bigfoot")
    Count404s.count("/nessie")

    assert Count404s.get_count("/nessie") == 3
    assert Count404s.get_count("/bigfoot") == 2

    assert Count404s.get_counts() == %{"/bigfoot" => 2, "/nessie" => 3}
  end

  test "can reset counts" do
    start_supervised!({Count404s, %{}})

    Count404s.count("/nessie")
    Count404s.count("/nessie")

    assert Count404s.get_counts() == %{"/nessie" => 2}

    Count404s.reset_counts()
    assert Count404s.get_counts() == %{}
  end
end
