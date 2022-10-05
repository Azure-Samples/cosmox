defmodule Cosmox.Structs.Collections.ConflictResolutionPolicy do
  @moduledoc false

  @derive [
    {Nestru.PreDecoder,
     %{
       "conflictResolutionPath" => :conflict_resolution_path,
       "conflictResolutionProcedure" => :conflict_resolution_procedure
     }},
    Nestru.Decoder
  ]

  defstruct mode: "",
            conflict_resolution_path: "",
            conflict_resolution_procedure: ""

  @type t() :: %__MODULE__{
          mode: binary(),
          conflict_resolution_path: binary(),
          conflict_resolution_procedure: binary()
        }
end
