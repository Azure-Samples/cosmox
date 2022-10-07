defmodule Cosmox.Structs.DocumentInfo do
  @moduledoc """
  Represents the information sent along with a document from the database.
  These information are not related to the document domain information, they represents database information
  regarding the document.
  The struct includes the partition key as well.
  """

  @derive Nestru.Decoder

  defstruct id: "",
            pk: "",
            _rid: "",
            _self: "",
            _etag: "",
            _attachments: "",
            _ts: 0

  @type t() :: %__MODULE__{
          id: binary(),
          pk: binary(),
          _rid: binary(),
          _self: binary(),
          _etag: binary(),
          _attachments: binary(),
          _ts: integer()
        }
end
