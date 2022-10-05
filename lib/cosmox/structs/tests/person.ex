defmodule Cosmox.Structs.Tests.Person do
  @moduledoc false

  @derive Nestru.Decoder

  defstruct id: "",
            pk: "",
            name: "",
            surname: "",
            age: 0

  @type t() :: %__MODULE__{
          id: binary(),
          pk: binary(),
          name: binary(),
          surname: binary(),
          age: non_neg_integer()
        }
end
