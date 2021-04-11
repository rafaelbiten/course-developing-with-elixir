defmodule Servy.Bear do
  @moduledoc false

  defstruct id: nil,
            name: "",
            type: "",
            hibernating: false

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          type: String.t(),
          hibernating: boolean()
        }
end
