defmodule Cosmox.Encryption do
  @moduledoc """
  Handles the header token encryption for REST calls to CosmosDB.
  """

  @doc """
  Generates an encrypted payload from the given one using the encryption required by CosmosDB, with the given key.
  """
  @spec get_encrypted_payload(payload :: binary(), key :: binary()) ::
          {:ok, binary()} | {:error, binary()}
  def get_encrypted_payload(payload, key) do
    with {:ok, decoded_key} <- decode_string(key) do
      encrypted_payload =
        decoded_key
        |> encrypt_payload(payload)
        |> encode_string()

      {:ok, encrypted_payload}
    end
  end

  @spec decode_string(string :: binary()) :: {:ok, binary()} | {:error, binary()}
  def decode_string(string) do
    case Base.decode64(string) do
      result = {:ok, _} -> result
      _ -> {:error, "Impossible to decode the given string key"}
    end
  end

  defp encode_string(string) do
    Base.encode64(string)
  end

  defp encrypt_payload(decoded_key, payload) do
    :sha256
    |> hmac_function(decoded_key, payload)

    # |> String.downcase()
  end

  if Code.ensure_loaded?(:crypto) and function_exported?(:crypto, :mac, 4) do
    defp hmac_function(digest, key, data) do
      :crypto.mac(:hmac, digest, key, data)
    end
  else
    defp hmac_function(digest, key, data) do
      :crypto.hmac(digest, key, data)
    end
  end
end
