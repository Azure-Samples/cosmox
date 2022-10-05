defmodule Cosmox.Structs.DocumentList do
  @moduledoc false

  alias Cosmox.Response.ErrorMessage

  @derive [
    {Nestru.PreDecoder, %{"Documents" => :documents}},
    Nestru.Decoder
  ]

  defstruct _rid: "",
            _count: 0,
            documents: []

  @type t() :: %__MODULE__{
          _rid: binary(),
          _count: non_neg_integer(),
          documents: list(map())
        }

  @doc """
  Tries to deserialize the documents in the data structure using the given struct.
  """
  @spec try_deserialize_documents(list :: t(), struct :: term) ::
          {:ok, list(term)}
          | {:error, ErrorMessage.t()}
  def try_deserialize_documents(%{documents: documents}, struct) do
    case documents |> Nestru.decode_from_list_of_maps(struct) do
      {:error, error} ->
        {:error,
         %{
           errors: ["There was an error while deserializing the map", "#{inspect(error)}"]
         }}

      result = {:ok, _} ->
        result
    end
  end
end
