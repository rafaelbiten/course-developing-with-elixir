defmodule Servy.Conn do
  @moduledoc false

  alias Servy.Conn

  defstruct method: "",
            path: "",
            resp_body: "",
            resp_content_type: "text/html",
            params: %{},
            headers: %{},
            status: nil

  @type t :: %__MODULE__{
          method: String.t(),
          path: String.t(),
          resp_body: String.t(),
          resp_content_type: String.t(),
          params: map(),
          headers: map(),
          status: integer()
        }

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
