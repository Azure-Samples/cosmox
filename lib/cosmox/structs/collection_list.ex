defmodule Cosmox.Structs.CollectionList do
  @moduledoc """
  Represents the object returned for querying a list of Collections (containers).
  """

  alias Cosmox.Structs.Collection

  @derive [
    {Nestru.PreDecoder, %{"DocumentCollections" => :collections}},
    {Nestru.Decoder, %{collections: [Collection]}}
  ]

  defstruct collections: []

  @type t() :: %__MODULE__{
          collections: list(%Collection{})
        }
end
