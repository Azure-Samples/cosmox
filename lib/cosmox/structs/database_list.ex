defmodule Cosmox.Structs.DatabaseList do
  @moduledoc """
  Represents the object returned for querying a list of databases.
  """

  alias Cosmox.Structs.Database

  @derive [
    {Nestru.PreDecoder, %{"Databases" => :databases}},
    {Nestru.Decoder, %{databases: [Database]}}
  ]

  defstruct databases: []

  @type t() :: %__MODULE__{
          databases: list(%Database{})
        }
end
