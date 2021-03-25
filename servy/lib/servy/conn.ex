defmodule Servy.Conn do
  alias Servy.Conn

  defstruct method: "",
            path: "",
            resp_body: "",
            data: %{},
            headers: %{},
            status: nil

  def full_status(%Conn{} = conn) do
    "#{conn.status} #{status_reason(conn.status)}"
  end

  defp status_reason(code) do
    case code do
      200 -> "OK"
      201 -> "Created"
      404 -> "Not Found"
      403 -> "Forbidden"
      500 -> "Internal server error"
    end
  end
end
