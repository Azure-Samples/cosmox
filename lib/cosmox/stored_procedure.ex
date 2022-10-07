defmodule Cosmox.StoredProcedure do
  @moduledoc """
  Manages the creation of stored procedures in CosmosDB
  """

  alias Cosmox.Helpers.ApiHelpers
  alias Cosmox.RestClient
  alias Cosmox.Structs.StoredProcedure

  @doc """
  Creates a stored procedure in the given database/container set.
  """
  @spec(
    create_stored_procedure(
      database_id :: binary(),
      container_id :: binary(),
      stored_procedure :: StoredProcedure.t()
    ) :: :ok,
    {:error, Cosmox.Response.ErrorMessage.t()}
  )
  def create_stored_procedure(database_id, container_id, %{
        name: sproc_name,
        body: sproc_body
      }) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = "#{resource_link}/sprocs"

    body =
      %{
        "id" => sproc_name,
        "body" => sproc_body
      }
      |> Jason.encode!()

    :sprocs
    |> ApiHelpers.call(:post, resource_link, resource_path, [], body)
    |> RestClient.hide_response()
  end

  @doc """
  Deletes a stored procedure in the given database/container set.
  """
  @spec(
    delete_stored_procedure(
      database_id :: binary(),
      container_id :: binary(),
      store_procedure_name :: binary()
    ) :: :ok,
    {:error, ErrorMessage.t()}
  )
  def delete_stored_procedure(database_id, container_id, stored_procedure_name) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}/sprocs/#{stored_procedure_name}"
    resource_path = "#{resource_link}"

    :sprocs
    |> ApiHelpers.call(:delete, resource_link, resource_path)
    |> RestClient.hide_response()
  end
end
