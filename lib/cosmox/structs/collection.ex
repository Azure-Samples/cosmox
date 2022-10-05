defmodule Cosmox.Structs.Collection do
  @moduledoc """
  Defines a collection informationa data structure.
  """

  alias Cosmox.Structs.PartitionKey

  alias Cosmox.Structs.Collections.{
    ConflictResolutionPolicy,
    GeospatialConfig,
    IndexingPolicy
  }

  @derive [
    {Nestru.PreDecoder,
     %{
       "indexingPolicy" => :indexing_policy,
       "partitionKey" => :partition_key,
       "conflictResolutionPolicy" => :conflict_resolution_policy,
       "geospatialConfig" => :geospatial_config
     }},
    {Nestru.Decoder,
     %{
       indexing_policy: IndexingPolicy,
       partition_key: PartitionKey,
       conflict_resolution_policy: ConflictResolutionPolicy,
       geospatial_config: GeospatialConfig
     }}
  ]

  defstruct id: "",
            indexing_policy: %IndexingPolicy{},
            partition_key: %PartitionKey{},
            conflict_resolution_policy: %ConflictResolutionPolicy{},
            geospatial_config: %GeospatialConfig{},
            _rid: "",
            _ts: 0,
            _self: "",
            _etag: "",
            _docs: "",
            _sprocs: "",
            _triggers: "",
            _udfs: "",
            _conflicts: ""

  @type t() :: %__MODULE__{
          id: binary(),
          indexing_policy: IndexingPolicy.t(),
          partition_key: PartitionKey.t(),
          conflict_resolution_policy: ConflictResolutionPolicy.t(),
          geospatial_config: GeospatialConfig.t(),
          _rid: binary(),
          _ts: non_neg_integer(),
          _self: binary(),
          _etag: binary(),
          _docs: binary(),
          _sprocs: binary(),
          _triggers: binary(),
          _udfs: binary(),
          _conflicts: binary()
        }
end
