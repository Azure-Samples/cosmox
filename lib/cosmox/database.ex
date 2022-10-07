defmodule Cosmox.Database do
  @moduledoc """
  Handles all the command to create, modify or delete a database.
  """

  alias Cosmox.Configuration
  alias Cosmox.Helpers.ApiHelpers
  alias Cosmox.Response.ErrorMessage
  alias Cosmox.RestClient
  alias Cosmox.Structs.Database
  alias Cosmox.Structs.DatabaseList

  @doc """
  Creates a new database, given the database id (the name)).

  ## Example

    iex> Cosmox.Database.create_database("test_db")
    {:ok,
    %Cosmox.Structs.Database{
      _colls: "colls/",
      _etag: "\"00006518-0000-0c00-0000-630dd4920000\"",
      _rid: "FONgAA==",
      _self: "dbs/FONgAA==/",
      _ts: 1661850770,
      _users: "users/",
      id: "test_db"
    }}

  """
  @spec create_database(database_id :: binary(), mode :: Configuration.database_throughput_mode()) ::
          {:ok, Database.t()}
          | {:error, ErrorMessage.t()}
  def create_database(database_id, mode \\ :none) do
    resource_link = ""
    resource_path = "/dbs"
    headers = Configuration.resource_creation_headers(mode)

    body = %{
      "id" => database_id
    }

    :dbs
    |> ApiHelpers.call(:post, resource_link, resource_path, headers, body)
    |> RestClient.try_decode_response(Database)
  end

  @doc """
  Returns a list of the database available on the CosmosDB instance.

  ## Example

    iex> Cosmox.Database.list_databases()
    {:ok,
    %Cosmox.Structs.DatabaseList{
      databases: [
        %Cosmox.Structs.Database{
          _colls: "colls/",
          _etag: "\"00006518-0000-0c00-0000-630dd4920000\"",
          _rid: "FONgAA==",
          _self: "dbs/FONgAA==/",
          _ts: 1661850770,
          _users: "users/",
          id: "test_db"
        }
      ]
    }

  """
  @spec list_databases() ::
          {:ok, DatabaseList.t()}
          | {:error, binary()}
          | {:error, Exception.t()}
  def list_databases do
    resource_link = ""
    resource_path = "/dbs"

    :dbs
    |> ApiHelpers.call(:get, resource_link, resource_path)
    |> RestClient.try_decode_response(DatabaseList)
  end

  @doc """
  Gets the database with the given database_id.

  ## Example

    iex(4)> Cosmox.Database.get_database("test_db")
    {:ok,
    %Cosmox.Structs.Database{
      _colls: "colls/",
      _etag: "\"00006518-0000-0c00-0000-630dd4920000\"",
      _rid: "FONgAA==",
      _self: "dbs/FONgAA==/",
      _ts: 1661850770,
      _users: "users/",
      id: "test_db"
    }}

  """
  @spec get_database(database_id :: binary()) :: {:ok, Database.t()} | {:error, ErrorMessage.t()}
  def get_database(database_id) do
    resource_link = "dbs/#{database_id}"
    resource_path = resource_link

    :dbs
    |> ApiHelpers.call(:get, resource_link, resource_path)
    |> RestClient.try_decode_response(Database)
  end

  @doc """
  Deletes the database with the given id.

  ## Example

    iex(5)> Cosmox.Database.delete_database("test_db")
    :ok

  """
  @spec delete_database(database_id :: binary()) :: :ok | {:error, ErrorMessage.t()}
  def delete_database(database_id) do
    resource_link = "dbs/#{database_id}"
    resource_path = resource_link

    :dbs
    |> ApiHelpers.call(:delete, resource_link, resource_path)
    |> RestClient.hide_response()
  end
end
