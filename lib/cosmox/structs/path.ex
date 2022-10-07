defmodule Cosmox.Structs.Path do
  @moduledoc """
  Struct to describe a path.
  """

  @derive Nestru.Decoder

  defstruct path: ""

  @type t() :: %__MODULE__{
          path: binary()
        }
end
