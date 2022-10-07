defmodule Cosmox.Structs.Collections.GeospatialConfig do
  @moduledoc false

  @derive Nestru.Decoder

  defstruct type: ""

  @type t() :: %__MODULE__{
          type: binary()
        }
end
