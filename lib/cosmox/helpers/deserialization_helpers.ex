defmodule Cosmox.Helpers.DeserializationHelpers do
  @moduledoc """
  Collection of helper functions to help deserialize to struct or simple maps.
  """

  alias Cosmox.Response.ErrorMessage

  @doc """
  Deserialises a string to the given structs, or to a simple map if no struct is given.
  """
  @spec deserialize(encoded_string :: binary(), struct :: module() | nil) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
  def deserialize(encoded_string, struct \\ nil) do
    with {:ok, json_result} <- deserialize_string(encoded_string),
         result = {:ok, _} <- parse_struct(json_result, struct) do
      result
    else
      error = {:error, %ErrorMessage{}} ->
        error

      error ->
        %{
          errors: [
            "There was an error while deserializing the response",
            "#{inspect(error)}"
          ]
        }
    end
  end

  @spec deserialize_string(encoded_string :: binary()) ::
          {:ok, map()}
          | {:error, ErrorMessage.t()}
  defp deserialize_string(encoded_string) do
    case Jason.decode(encoded_string) do
      result = {:ok, _} ->
        result

      {:error, %{position: position, data: data}} ->
        %ErrorMessage{
          errors: [
            "An error occurred in the deserialization of the response.",
            "Error at line #{position}",
            data,
            encoded_string
          ]
        }
    end
  end

  @spec parse_struct(json_result :: map(), struct :: module() | nil) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
  defp parse_struct(json_result, nil), do: {:ok, json_result}

  defp parse_struct(json_result, struct) do
    case Nestru.decode_from_map(json_result, struct) do
      result = {:ok, _} ->
        result

      {:error, error_struct = %{message: message}} ->
        {:error, %ErrorMessage{
          errors: [
            message,
            "#{inspect(error_struct)}"
          ]
        }}

      {:error, error} ->
        {:error, %ErrorMessage{
          errors: [
            "An error occurred while parsing the response",
            "#{inspect(error)}"
          ]
        }}
    end
  end
end
