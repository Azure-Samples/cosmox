defmodule Cosmox.Auth do
  @moduledoc """
  Handles the generation of the authorisation token for every REST call to CosmosDB.
  """

  alias Cosmox.Encryption
  alias Cosmox.Helpers.DateHelpers

  @type resource_type() :: :dbs | :colls | :docs | :sprocs | :pkranges

  @key_type "master"

  @token_version "1.0"

  @doc """
  Generates the authorisation signature from the resource types.
  """
  @spec generate_master_key_authorization_signature(
          verb :: binary(),
          resource_type :: resource_type(),
          resource_link :: binary(),
          date :: binary() | NaiveDateTime.t(),
          key :: binary()
        ) :: {:ok, binary()} | {:error, binary()}
  def generate_master_key_authorization_signature(verb, resource_type, resource_link, date, key)

  def generate_master_key_authorization_signature(verb, resource_type, resource_link, date, key)
      when is_binary(date) do
    with payload <- generate_payload(verb, resource_type, resource_link, date),
         {:ok, encrypted_payload} <- Encryption.get_encrypted_payload(payload, key) do
      result =
        encrypted_payload
        |> encode_url_payload()

      {:ok, result}
    end
  end

  def generate_master_key_authorization_signature(verb, resource_type, resource_link, date, key) do
    converted_date = DateHelpers.convert_naivedatetime_to_rfc_7231(date)

    generate_master_key_authorization_signature(
      verb,
      resource_type,
      resource_link,
      converted_date,
      key
    )
  end

  defp generate_payload(verb, resource_type, resource_link, date) do
    {verb, resource_type, resource_link, date} = {
      verb |> String.downcase(),
      resource_type |> Atom.to_string() |> String.downcase(),
      resource_link,
      date |> String.downcase()
    }

    "#{verb}\n#{resource_type}\n#{resource_link}\n#{date}\n\n"
  end

  defp encode_url_payload(payload) do
    URI.encode_www_form("type=#{@key_type}&ver=#{@token_version}&sig=#{payload}")
  end
end
