defmodule Cosmox.Structs.PartitionKey do
  @moduledoc """
  Represents the partition key for a collection.
  """

  @derive Nestru.Decoder

  defstruct paths: [],
            kind: "",
            version: 0

  @type t() :: %__MODULE__{
          paths: list(binary()),
          kind: binary(),
          version: non_neg_integer()
        }
end
