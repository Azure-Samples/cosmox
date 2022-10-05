defmodule Cosmox.Structs.Database do
  @moduledoc """
  Represents a database from the CosmosDB API.
  """

  @derive Nestru.Decoder

  defstruct id: "",
            _rid: "",
            _self: "",
            _etag: "",
            _colls: "",
            _users: "",
            _ts: ""

  @type t() :: %{
          id: binary(),
          _rid: binary(),
          _self: binary(),
          _etag: binary(),
          _colls: binary(),
          _users: binary(),
          _ts: binary()
        }
end
