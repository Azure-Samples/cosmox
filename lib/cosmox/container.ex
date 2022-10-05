defmodule Cosmox.Container do
  @moduledoc """
  Handles the operation concerning the database containers.
  """

  import Cosmox.Configuration

  alias Cosmox.Helpers.ApiHelpers
  alias Cosmox.Response.ErrorMessage
  alias Cosmox.RestClient
  alias Cosmox.Structs.Collection
  alias Cosmox.Structs.PartitionKeyRangeResponse

  @doc """
  Creates a continaer with the given id, inside the database with the given database id.
  The function does not check whether the database exists or not, it will delegate this
  check directly to Cosmos.

  ## Example

    iex> Cosmox.Database.create_database("test_db")
    {:ok,
    %Cosmox.Structs.Database{
      _colls: "colls/",
      _etag: "\"00006618-0000-0c00-0000-630ddb830000\"",
      _rid: "lJweAA==",
      _self: "dbs/lJweAA==/",
      _ts: 1661852547,
      _users: "users/",
      id: "test_db"
    }}

    iex> Cosmox.Container.create_container("test_db", "test_container")
    {:ok,
    %Cosmox.Structs.Collection{
      _conflicts: "conflicts/",
      _docs: "docs/",
      _etag: "\"00006818-0000-0c00-0000-630ddbc20000\"",
      _rid: "lJweAM76mmE=",
      _self: "dbs/lJweAA==/colls/lJweAM76mmE=/",
      _sprocs: "sprocs/",
      _triggers: "triggers/",
      _ts: 1661852610,
      _udfs: "udfs/",
      conflict_resolution_policy: %Cosmox.Structs.Collections.ConflictResolutionPolicy{
        conflict_resolution_path: "/_ts",
        conflict_resolution_procedure: "",
        mode: "LastWriterWins"
      },
      geospatial_config: %Cosmox.Structs.Collections.GeospatialConfig{
        type: "Geography"
      },
      id: "test_container",
      indexing_policy: %Cosmox.Structs.Collections.IndexingPolicy{
        automatic: true,
        excludedPaths: [%Cosmox.Structs.Path{path: "/\"_etag\"/?"}],
        includedPaths: [%Cosmox.Structs.Path{path: "/*"}],
        indexingMode: "consistent"
      },
      partition_key: %Cosmox.Structs.PartitionKey{
        kind: "Hash",
        paths: ["/pk"],
        version: 2
      }
    }}

  """
  @spec create_container(
          database_id :: binary(),
          container_id :: binary(),
          mode :: Cosmox.Configuration.database_throughput_mode()
        ) ::
          {:ok, Collection.t()}
          | {:error, ErrorMessage.t()}
  def create_container(database_id, container_id, mode \\ :none) do
    resource_link = "dbs/#{database_id}"
    resource_path = "/#{resource_link}/colls"
    headers = resource_creation_headers(mode)

    body = %{
      "id" => container_id,
      "partitionKey" => %{
        "paths" => ["/pk"],
        "kind" => "Hash",
        "Version" => 2
      }
    }

    response =
      :colls
      |> ApiHelpers.call(:post, resource_link, resource_path, headers, body)
      |> RestClient.try_decode_response(Collection)

    case response do
      {:error, error = %ErrorMessage{}} ->
        {:error, error}

      {:ok, collection} ->
        {:ok, collection}
    end
  end

  @doc """
  Gets the container with the given name within the database with the given id.

  ## Example

    iex> Cosmox.Container.create_container("test_db", "test_container")
    {:ok,
    %Cosmox.Structs.Collection{
      _conflicts: "conflicts/",
      _docs: "docs/",
      _etag: "\"00006818-0000-0c00-0000-630ddbc20000\"",
      _rid: "lJweAM76mmE=",
      _self: "dbs/lJweAA==/colls/lJweAM76mmE=/",
      _sprocs: "sprocs/",
      _rid: "lJweAM76mmE=",
      _self: "dbs/lJweAA==/colls/lJweAM76mmE=/",
      _sprocs: "sprocs/",
      _triggers: "triggers/",
      _ts: 1661852610,
      _udfs: "udfs/",
      conflict_resolution_policy: %Cosmox.Structs.Collections.ConflictResolutionPolicy{
        conflict_resolution_path: "/_ts",
        conflict_resolution_procedure: "",
        mode: "LastWriterWins"
      },
      geospatial_config: %Cosmox.Structs.Collections.GeospatialConfig{
        type: "Geography"
      },
      id: "test_container",
      indexing_policy: %Cosmox.Structs.Collections.IndexingPolicy{
        automatic: true,
        excludedPaths: [%Cosmox.Structs.Path{path: "/\"_etag\"/?"}],
        includedPaths: [%Cosmox.Structs.Path{path: "/*"}],
        indexingMode: "consistent"
      },
      partition_key: %Cosmox.Structs.PartitionKey{
        kind: "Hash",
        paths: ["/pk"],
        version: 2
      }
    }}

  """
  @spec get_container(database_id :: binary(), container_id :: binary()) ::
          {:ok, Collection.t()}
          | {:error, ErrorMessage.t()}
  def get_container(database_id, container_id) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = resource_link

    :colls
    |> ApiHelpers.call(:get, resource_link, resource_path)
    |> RestClient.try_decode_response(Collection)
  end

  @doc """
  Gets the container partition keys.

  ## Example

    iex(10)> Cosmox.Container.get_container_partition_keys("test_db", "test_container")
    {:ok,
    %Cosmox.Structs.PartitionKeyRangeResponse{
      _count: 1,
      _rid: "lJweAM76mmE=",
      partition_key_ranges: [
        %Cosmox.Structs.PartitionKeyRange{
          _etag: "\"00006a18-0000-0c00-0000-630ddbc20000\"",
          _rid: "lJweAM76mmECAAAAAAAAUA==",
          _self: "dbs/lJweAA==/colls/lJweAM76mmE=/pkranges/lJweAM76mmECAAAAAAAAUA==/",
          _ts: 1661852610,
          id: "0",
          max_exclusive: "FF",
          min_inclusive: "",
          parents: [],
          rid_prefix: 0,
          status: "online",
          throughput_fraction: 1
        }
      ]
    }}

  """
  @spec get_container_partition_keys(database_id :: binary(), container_id :: binary()) ::
          {:ok, Collection.t()}
          | {:error, ErrorMessage.t()}
  def get_container_partition_keys(database_id, container_id) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = "/#{resource_link}/pkranges"

    :pkranges
    |> ApiHelpers.call(:get, resource_link, resource_path)
    |> RestClient.try_decode_response(PartitionKeyRangeResponse)
  end

  @doc """
  Deletes the given container within the given database id.

  ## Example

    iex(11)> Cosmox.Container.delete_container("test_db", "test_container")
    :ok

  """
  @spec delete_container(database_id :: binary(), container_id :: binary()) ::
          :ok
          | {:error, ErrorMessage.t()}
  def delete_container(database_id, container_id) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = resource_link

    :colls
    |> ApiHelpers.call(:delete, resource_link, resource_path)
    |> RestClient.hide_response()
  end
end
