defmodule Cosmox.Requests.RequestHeaders do
  @moduledoc """
  Handles the construction and verification of the default request headers.
  """

  alias Cosmox.Helpers.DateHelpers

  @current_api_version "2018-12-31"

  @doc """
  Gets the current CosmosDB REST api version.
  """
  @spec get_current_api_version() :: binary()
  def get_current_api_version, do: @current_api_version

  @doc """
  Gets the default headers, provided with the command date and the authorization string.
  """
  @spec get_default_headers(
          authorization_string :: binary(),
          request_date :: NaiveDateTime.t() | binary()
        ) :: Finch.Request.headers()
  def get_default_headers(authorization_string, request_date)
      when is_nil(authorization_string) or is_nil(request_date) do
    raise "Authorization string and Request date should not be null"
  end

  def get_default_headers(authorization_string, request_date) when is_binary(request_date) do
    [
      {"Accept", "application/json"},
      {"authorization", authorization_string},
      {"x-ms-date", request_date},
      {"x-ms-version", @current_api_version}
    ]
  end

  def get_default_headers(authorization_string, request_date) do
    get_default_headers(
      authorization_string,
      DateHelpers.convert_naivedatetime_to_rfc_7231(request_date)
    )
  end
end
