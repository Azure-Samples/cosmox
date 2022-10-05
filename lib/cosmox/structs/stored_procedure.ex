defmodule Cosmox.Structs.StoredProcedure do
  @moduledoc """
  Represents a stored produce in CosmosDB.
  """

  defstruct name: "",
            body: ""

  @type t() :: %__MODULE__{
          name: binary(),
          body: binary()
        }
end
