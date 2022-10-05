defmodule Cosmox.Structs.PartitionKeyRangeResponse do
  @moduledoc false

  alias Cosmox.Structs.PartitionKeyRange

  @derive [
    {Nestru.PreDecoder, %{"PartitionKeyRanges" => :partition_key_ranges}},
    {Nestru.Decoder, %{partition_key_ranges: [PartitionKeyRange]}}
  ]

  defstruct _rid: "",
            _count: 0,
            partition_key_ranges: []

  @type t() :: %__MODULE__{
          _rid: binary(),
          _count: non_neg_integer(),
          partition_key_ranges: list(PartitionKeyRange.t())
        }
end
