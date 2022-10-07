defmodule Cosmox.Helpers.ApiHelpers do
  @moduledoc """
  Defines a series of helper functions to incapsulate the common behaviour of calling the Cosmos API.
  """

  alias Cosmox.Auth
  alias Cosmox.Configuration
  alias Cosmox.Helpers.DateHelpers
  alias Cosmox.Requests.RequestHeaders
  alias Cosmox.Response.ErrorMessage
  alias Cosmox.RestClient

  alias Finch.Response

  @spec call(
          resource_type :: Auth.resource_type(),
          method :: RestClient.method(),
          resource_link :: binary(),
          resource_path :: binary(),
          headers :: RestClient.headers(),
          body :: struct() | map() | binary() | nil
        ) ::
          {:ok, Response.t()}
          | {:error, ErrorMessage.t()}
  def call(resource_type, method, resource_link, resource_path, headers \\ [], body \\ nil) do
    {cosmos_db_host, cosmos_db_key} = Configuration.get_cosmos_db_config()

    now = DateHelpers.now_rfc_7231()

    master_key_authorization_signature =
      Auth.generate_master_key_authorization_signature(
        method |> method_to_string(),
        resource_type,
        resource_link,
        now,
        cosmos_db_key
      )

    case master_key_authorization_signature do
      {:ok, authorization_token} ->
        url =
          case resource_path |> String.at(0) do
            "/" -> "#{cosmos_db_host}#{resource_path}"
            _ -> "#{cosmos_db_host}/#{resource_path}"
          end

        headers =
          RequestHeaders.get_default_headers(authorization_token, now)
          |> Enum.concat(headers)

        with {:ok, body} <- body |> serialize_body() do
          RestClient.perform_request(method, url, headers, body)
        end

      {:error, error} ->
        {:error, %ErrorMessage{errors: [error]}}
    end
  end

  @spec method_to_string(method :: RestClient.method()) :: binary()
  defp method_to_string(method) do
    method
    |> Atom.to_string()
    |> String.upcase()
  end

  @spec serialize_body(body :: struct() | map() | binary() | nil) ::
          {:ok, binary() | nil}
          | {:error, ErrorMessage.t()}
  defp serialize_body(body) when is_struct(body) do
    body
    |> Map.from_struct()
    |> serialize_body()
  end

  defp serialize_body(body) when is_map(body) do
    case body |> Jason.encode() do
      result = {:ok, _} ->
        result

      {:error, jason_error} ->
        {:error,
         %ErrorMessage{
           errors: [
             "There was an error while deserializing the body",
             "Body: #{inspect(body)}",
             "#{inspect(jason_error)}"
           ]
         }}
    end
  end

  defp serialize_body(body), do: {:ok, body}
end
