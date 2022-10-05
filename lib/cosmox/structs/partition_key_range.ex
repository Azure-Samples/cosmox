defmodule Cosmox.Structs.PartitionKeyRange do
  @moduledoc false

  @derive [
    {Nestru.PreDecoder,
     %{
       "minInclusive" => :min_inclusive,
       "maxExclusive" => :max_exclusive,
       "ridPrefix" => :rid_prefix,
       "throughputFraction" => :throughput_fraction
     }},
    Nestru.Decoder
  ]

  defstruct _rid: "",
            id: "",
            _etag: "",
            min_inclusive: "",
            max_exclusive: "",
            rid_prefix: 0,
            _self: "",
            throughput_fraction: 0,
            status: "",
            parents: [],
            _ts: 0

  @type t() :: %__MODULE__{
          _rid: binary(),
          id: binary(),
          _etag: binary(),
          min_inclusive: binary(),
          max_exclusive: binary(),
          rid_prefix: non_neg_integer(),
          _self: binary(),
          throughput_fraction: non_neg_integer(),
          status: binary(),
          parents: list(binary()),
          _ts: non_neg_integer()
        }
end
