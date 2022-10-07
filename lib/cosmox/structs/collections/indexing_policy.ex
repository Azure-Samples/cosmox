defmodule Cosmox.Structs.Collections.IndexingPolicy do
  @moduledoc """
  Collection indexing policy.
  """

  alias Cosmox.Structs.Path

  @derive [
    {Nestru.PreDecoder,
     %{
       "includedPaths" => :included_paths,
       "excludedPaths" => :excluded_paths,
       "indexingMode" => :indexing_mode
     }},
    {Nestru.Decoder,
     %{
       includedPaths: [Path],
       excludedPaths: [Path]
     }}
  ]

  defstruct indexingMode: "",
            automatic: true,
            includedPaths: [],
            excludedPaths: []

  @type t() :: %__MODULE__{
          indexingMode: binary(),
          automatic: boolean(),
          includedPaths: list(Path.t()),
          excludedPaths: list(Path.t())
        }
end
