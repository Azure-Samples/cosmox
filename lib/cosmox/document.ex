defmodule Cosmox.Document do
  @moduledoc """
  The API to manage the documents inside a container.
  """

  alias Cosmox.Helpers.ApiHelpers
  alias Cosmox.Helpers.DeserializationHelpers
  alias Cosmox.Response.ErrorMessage
  alias Cosmox.RestClient
  alias Cosmox.Structs.{DocumentInfo, DocumentList}

  alias Finch.Response

  @doc """
  Creates a document in the given container in the given database.
  The function accept both a struct and a map, but either must have a `pk` key
  to represent the partition key in which the document will be inserted.
  The **partition key** is an important concept in Cosmos, please refer to
  Cosmos documentation for more information.

  ## Examples

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}

    iex> map = %{
    ...>   "id" => "2",
    ...>   "pk" => "pk1",
    ...>   "name" => "Some Other Name",
    ...>   "surname" => "Some Other Surname",
    ...>   "age" => 45
    ...> }
    %{
      "age" => 45,
      "id" => "2",
      "name" => "Some Other Name",
      "pk" => "pk1",
      "surname" => "Some Other Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", map)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d302b4a3-0000-0c00-0000-630de9900000\"",
      _rid: "lJweAJDf4xcCAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcCAAAAAAAAAA==/",
      _ts: 1661856144,
      pk: "pk1"
    }}

  """
  @spec create_document(
          database_id :: binary(),
          container_id :: binary(),
          item :: term | map(),
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
  def create_document(database_id, container_id, item, struct \\ nil)

  def create_document(database_id, container_id, item = %{id: _, pk: pk}, struct),
    do: create_document_internal(database_id, container_id, item, pk, struct)

  def create_document(database_id, container_id, item = %{"id" => _, "pk" => pk}, struct),
    do: create_document_internal(database_id, container_id, item, pk, struct)

  def create_document(_, _, _, _),
    do:
      {:error,
       %ErrorMessage{
         errors: "Invalid item"
       }}

  @spec create_document_internal(
          database_id :: binary(),
          container_id :: binary(),
          item :: term | map(),
          partition_key :: binary(),
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
  defp create_document_internal(database_id, container_id, item, partition_key, struct) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = "/#{resource_link}/docs"
    headers = document_headers(partition_key)

    body =
      case item do
        i when is_struct(i) -> Map.from_struct(i)
        i -> i
      end

    :docs
    |> ApiHelpers.call(:post, resource_link, resource_path, headers, body)
    |> RestClient.try_decode_response(struct || DocumentInfo)
  end

  @doc """
  List all the documents on the given db/container/partition key.
  By giving the struct in input, the library will try deserialize the list item to that.

  ## Examples

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}
    iex> map = %{
    ...>   "id" => "2",
    ...>   "pk" => "pk1",
    ...>   "name" => "Some Other Name",
    ...>   "surname" => "Some Other Surname",
    ...>   "age" => 45
    ...> }
    %{
      "age" => 45,
      "id" => "2",
      "name" => "Some Other Name",
      "pk" => "pk1",
      "surname" => "Some Other Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", map)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d302b4a3-0000-0c00-0000-630de9900000\"",
      _rid: "lJweAJDf4xcCAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcCAAAAAAAAAA==/",
      _ts: 1661856144,
      pk: "pk1"
    }}
    iex> Cosmox.Document.list_documents("test_db", "test_container", "pk1")
    {:ok,
    [
      %{
        "_attachments" => "attachments/",
        "_etag" => "\"d1028ad3-0000-0c00-0000-630de4900000\"",
        "_rid" => "lJweAJDf4xcBAAAAAAAAAA==",
        "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
        "_ts" => 1661854864,
        "age" => 55,
        "id" => "1",
        "name" => "Some Name",
        "pk" => "pk1",
        "surname" => "Some Surname"
      },
      %{
        "_attachments" => "attachments/",
        "_etag" => "\"d302b4a3-0000-0c00-0000-630de9900000\"",
        "_rid" => "lJweAJDf4xcCAAAAAAAAAA==",
        "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcCAAAAAAAAAA==/",
        "_ts" => 1661856144,
        "age" => 45,
        "id" => "2",
        "name" => "Some Other Name",
        "pk" => "pk1",
        "surname" => "Some Other Surname"
      }
    ]}
    iex> Cosmox.Document.list_documents("test_db", "test_container", "pk1", Cosmox.Structs.Tests.Person)
    {:ok,
    [
      %Cosmox.Structs.Tests.Person{
        age: 55,
        id: "1",
        name: "Some Name",
        pk: "pk1",
        surname: "Some Surname"
      },
      %Cosmox.Structs.Tests.Person{
        age: 45,
        id: "2",
        name: "Some Other Name",
        pk: "pk1",
        surname: "Some Other Surname"
      }
    ]}

  """
  @spec list_documents(
          database_id :: binary(),
          container_id :: binary(),
          partition_key :: binary(),
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  def list_documents(database_id, container_id, partition_key, struct \\ nil) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = "#{resource_link}/docs"
    headers = document_headers(partition_key)

    response =
      :docs
      |> ApiHelpers.call(:get, resource_link, resource_path, headers)
      |> RestClient.try_decode_response(DocumentList)

    with {:ok, response} <- response do
      case struct do
        nil -> {:ok, response.documents}
        s -> response |> DocumentList.try_deserialize_documents(s)
      end
    end
  end

  @doc """
  List all the documents on the given db/container/partition key.
  By giving the struct in input, the library will try deserialize the list to that.

  ## Example

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}
    iex> Cosmox.Document.get_document("test_db", "test_container", "1", "pk1")
    {:ok,
    %{
      "_attachments" => "attachments/",
      "_etag" => "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      "_rid" => "lJweAJDf4xcBAAAAAAAAAA==",
      "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      "_ts" => 1661854864,
      "age" => 55,
      "id" => "1",
      "name" => "Some Name",
      "pk" => "pk1",
      "surname" => "Some Surname"
    }
    iex> Cosmox.Document.get_document("test_db", "test_container", "1", "pk1", Cosmox.Structs.Tests.Person)
    {:ok,
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }}

  """
  @spec get_document(
          database_id :: binary(),
          container_id :: binary(),
          id :: binary(),
          partition_key :: binary(),
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  def get_document(database_id, container_id, id, partition_key, struct \\ nil) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}/docs/#{id}"
    resource_path = resource_link
    headers = document_headers(partition_key)

    :docs
    |> ApiHelpers.call(:get, resource_link, resource_path, headers)
    |> parse_item(struct)
  end

  @doc """
  Replaces the content of the document identified by the id and the partition key
  given in input.

  ## Example

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}
    iex> person = \\
    ...>   person \\
    ...>   |> Map.put(:name, "Some Other Name")
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Other Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.replace_document("test_db", "test_container", "1", person)
    {:ok,
    %{
      "_attachments" => "attachments/",
      "_etag" => "\"e00253d8-0000-0c00-0000-630e0b150000\"",
      "_rid" => "lJweAJDf4xcBAAAAAAAAAA==",
      "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      "_ts" => 1661864725,
      "age" => 55,
      "id" => "1",
      "name" => "Some Name",
      "pk" => "pk1",
      "surname" => "Some Surname"
    }}

  """
  @spec replace_document(
          database_id :: binary(),
          container_id :: binary(),
          id :: binary(),
          item :: map() | struct(),
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  def replace_document(database_id, container_id, id, item, struct \\ nil) do
    replace_document_internal(database_id, container_id, id, item, struct)
  end

  @spec replace_document_internal(
          database_id :: binary(),
          container_id :: binary(),
          id :: binary(),
          item :: map() | struct(),
          struct :: module() | nil,
          partition_key :: binary() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  defp replace_document_internal(
         database_id,
         container_id,
         id,
         item,
         struct,
         partition_key \\ nil
       )

  defp replace_document_internal(
         database_id,
         container_id,
         id,
         item = %{pk: partition_key},
         struct,
         nil
       ) do
    replace_document_internal(database_id, container_id, id, item, struct, partition_key)
  end

  defp replace_document_internal(
         database_id,
         container_id,
         id,
         item = %{"pk" => partition_key},
         struct,
         nil
       ) do
    replace_document_internal(database_id, container_id, id, item, struct, partition_key)
  end

  defp replace_document_internal(database_id, container_id, id, item, struct, partition_key)
       when not is_nil(partition_key) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}/docs/#{id}"
    resource_path = resource_link
    headers = document_headers(partition_key)

    body =
      case item do
        i when is_struct(i) -> Map.from_struct(i)
        i -> i
      end

    :docs
    |> ApiHelpers.call(:put, resource_link, resource_path, headers, body)
    |> parse_item(struct)
  end

  defp replace_document_internal(_, _, _, item, _, _) do
    {:error,
     %ErrorMessage{
       errors: [
         "The item in input does not have the `pk` key for the partition key.",
         "#{inspect(item)}"
       ]
     }}
  end

  @doc """
  Patches some fields of an existing document, provided the key of the property, and its value.

  ## Example

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}
    iex> Cosmox.Document.patch_document("test_db", "test_container", "1", "pk1", {
    ...>   :surname |> Atom.to_string(),
    ...>   "Some Other Surname"
    ...> })
    {:ok,
    %{
      "_attachments" => "attachments/",
      "_etag" => "\"e402e76f-0000-0c00-0000-630e14490000\"",
      "_rid" => "lJweAJDf4xcBAAAAAAAAAA==",
      "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      "_ts" => 1661867081,
      "age" => 55,
      "id" => "1",
      "name" => "Some Name",
      "pk" => "pk1",
      "surname" => "Some Other Surname"
    }}
  """
  @spec patch_document(
          database_id :: binary(),
          container_id :: binary(),
          id :: binary(),
          partition_key :: binary(),
          patch :: {key :: binary(), value :: binary()},
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  def patch_document(database_id, container_id, id, partition_key, {key, value}, struct \\ nil) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}/docs/#{id}"
    resource_path = resource_link
    headers = document_headers(partition_key)
    patched_value = parse_patched_value(value)

    body = """
    {
      "operations": [
        {
          "op": "set",
          "path": "/#{key}",
          "value": #{patched_value}
        }
      ]
    }
    """

    :docs
    |> ApiHelpers.call(:patch, resource_link, resource_path, headers, body)
    |> parse_item(struct)
  end

  @doc """
  Deletes the document from the given database/container.

  ## Example

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}
    iex> Cosmox.Document.delete_document("test_db", "test_container", "1", "pk1")
    :ok
  """
  @spec delete_document(
          database_id :: binary(),
          container_id :: binary(),
          id :: binary(),
          partition_key :: binary()
        ) ::
          :ok
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  def delete_document(database_id, container_id, id, partition_key) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}/docs/#{id}"
    resource_path = resource_link
    headers = document_headers(partition_key)

    :docs
    |> ApiHelpers.call(:delete, resource_link, resource_path, headers)
    |> RestClient.hide_response()
  end

  @doc """
  Applies the query to the specified database/container set passed in input, with the given parameters.
  This function will apply the query only on a particular partition key, that will have to be defined in the query.
  This function will not apply the partition key automatically: the partition key will have to be specified manually
  in the query by adding a filter over the `pk` field of the collection, and by subsequently adding the related
  parameter in the parameter list.

  ## Example

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}
    iex> Cosmox.Document.query_documents("test_db", "test_container", "pk1", {
    ...>   "SELECT * FROM c WHERE c.name = @p1",
    ...>   [
    ...>     {"@p1", "Some Name"}
    ...>   ]
    ...> }, Cosmox.Structs.Tests.Person)
    {:ok,
    [
      %Cosmox.Structs.Tests.Person{
        age: 55,
        id: "1",
        name: "Some Name",
        pk: "pk1",
        surname: "Some Surname"
      }
    ]}

  """
  @spec query_documents(
          database_id :: binary(),
          container_id :: binary(),
          partition_key :: binary(),
          {query :: binary(), parameters :: list({key :: binary(), value :: any()})},
          struct :: module() | nil
        ) :: {:ok, term} | {:error, ErrorMessage.t()}

  # {:ok, term | map()}
  # | {:error, ErrorMessage.t()}
  def query_documents(
        database_id,
        container_id,
        partition_key,
        {query, parameters},
        struct \\ nil
      ) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = "#{resource_link}/docs"
    headers = document_query_headers(partition_key)

    parameters =
      parameters
      |> build_query_params()

    body =
      %{
        "query" => query,
        "parameters" => parameters
      }
      |> Jason.encode!()

    response =
      :docs
      |> ApiHelpers.call(:post, resource_link, resource_path, headers, body)
      |> RestClient.try_decode_response(DocumentList)

    with {:ok, response} <- response do
      case struct do
        nil -> {:ok, response.documents}
        s -> response |> DocumentList.try_deserialize_documents(s)
      end
    end
  end

  @doc """
  Applies the query to the specified database/container set passed in input, with the given parameters.
  This query will span data across partitions.

  ## Examples

    iex> person = %Cosmox.Structs.Tests.Person{
    ...>   id: "1",
    ...>   pk: "pk1",
    ...>   name: "Some Name",
    ...>   surname: "Some Surname",
    ...>   age: 55
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 55,
      id: "1",
      name: "Some Name",
      pk: "pk1",
      surname: "Some Surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"d1028ad3-0000-0c00-0000-630de4900000\"",
      _rid: "lJweAJDf4xcBAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcBAAAAAAAAAA==/",
      _ts: 1661854864,
      pk: "pk1"
    }}
    iex> person_second_part = %Cosmox.Structs.Tests.Person{
    ...>   id: "2",
    ...>   pk: "pk2",
    ...>   name: "Second pk name",
    ...>   surname: "Second pk surname",
    ...>   age: 45
    ...> }
    %Cosmox.Structs.Tests.Person{
      age: 45,
      id: "2",
      name: "Second pk name",
      pk: "pk2",
      surname: "Second pk surname"
    }
    iex> Cosmox.Document.create_document("test_db", "test_container", person_second_part)
    {:ok,
    %Cosmox.Structs.DocumentInfo{
      _attachments: "attachments/",
      _etag: "\"e502d3e3-0000-0c00-0000-630e181b0000\"",
      _rid: "lJweAJDf4xcEAAAAAAAAAA==",
      _self: "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcEAAAAAAAAAA==/",
      _ts: 1661868059,
      pk: "pk2"
    }}
    iex> Cosmox.Document.query_documents_cross_partition("test_db", "test_container", {
    ...>   "SELECT * FROM c WHERE c.age > @p1",
    ...>   [
    ...>     {"@p1", 30}
    ...>   ]
    ...> })
    {:ok,
    [
      %{
        "_attachments" => "attachments/",
        "_etag" => "\"e402ceb5-0000-0c00-0000-630e15030000\"",
        "_rid" => "lJweAJDf4xcDAAAAAAAAAA==",
        "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcDAAAAAAAAAA==/",
        "_ts" => 1661867267,
        "age" => 55,
        "id" => "1",
        "name" => "Some Name",
        "pk" => "pk1",
        "surname" => "Some Surname"
      },
      %{
        "_attachments" => "attachments/",
        "_etag" => "\"e502d3e3-0000-0c00-0000-630e181b0000\"",
        "_rid" => "lJweAJDf4xcEAAAAAAAAAA==",
        "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcEAAAAAAAAAA==/",
        "_ts" => 1661868059,
        "age" => 45,
        "id" => "2",
        "name" => "Second pk name",
        "pk" => "pk2",
        "surname" => "Second pk surname"
      }
    ]}
    iex> Cosmox.Document.query_documents_cross_partition("test_db", "test_container", {
    ...>   "SELECT * FROM c WHERE c.age > @p1",
    ...>   [
    ...>     {"@p1", 50}
    ...>   ]
    ...> })
    {:ok,
    [
      %{
        "_attachments" => "attachments/",
        "_etag" => "\"e402ceb5-0000-0c00-0000-630e15030000\"",
        "_rid" => "lJweAJDf4xcDAAAAAAAAAA==",
        "_self" => "dbs/lJweAA==/colls/lJweAJDf4xc=/docs/lJweAJDf4xcDAAAAAAAAAA==/",
        "_ts" => 1661867267,
        "age" => 55,
        "id" => "1",
        "name" => "Some Name",
        "pk" => "pk1",
        "surname" => "Some Surname"
      }
    ]}

  """
  @spec query_documents_cross_partition(
          database_id :: binary(),
          container_id :: binary(),
          {query :: binary(), parameters :: list({key :: binary(), value :: any()})},
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  def query_documents_cross_partition(
        database_id,
        container_id,
        {query, parameters},
        struct \\ nil
      ) do
    resource_link = "dbs/#{database_id}/colls/#{container_id}"
    resource_path = "#{resource_link}/docs"

    headers =
      document_query_headers()
      |> Enum.concat(document_query_cross_partition_headers())

    parameters =
      parameters
      |> build_query_params()

    body =
      %{
        "query" => query,
        "parameters" => parameters
      }
      |> Jason.encode!()

    response =
      :docs
      |> ApiHelpers.call(:post, resource_link, resource_path, headers, body)
      |> RestClient.try_decode_response(DocumentList)

    with {:ok, response} <- response do
      case struct do
        nil -> {:ok, response.documents}
        s -> response |> DocumentList.try_deserialize_documents(s)
      end
    end
  end

  @spec build_query_params(list({key :: binary(), value :: any()})) :: list(map())
  defp build_query_params(params) do
    params
    |> Enum.map(fn {key, value} ->
      %{
        "name" => key,
        "value" => value
      }
    end)
  end

  @spec parse_patched_value(value :: any()) :: binary()
  defp parse_patched_value(value) when is_binary(value), do: "\"#{value}\""
  defp parse_patched_value(value) when is_number(value), do: "#{value}"
  defp parse_patched_value(value) when is_boolean(value), do: "#{inspect(value)}"
  defp parse_patched_value(value), do: Jason.encode!(value)

  @spec parse_item(
          response :: {:ok, Response.t()} | {:error, ErrorMessage.t()},
          struct :: module() | nil
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
          | {:error | any()}
  defp parse_item({:ok, %{status: status_code, body: body}}, nil) when status_code < 300,
    do:
      body
      |> DeserializationHelpers.deserialize()

  defp parse_item(response = {:ok, %{status: status_code}}, struct) when status_code < 300,
    do:
      response
      |> RestClient.try_decode_response(struct)

  defp parse_item({:ok, %{status: status_code, body: body}}, _),
    do: RestClient.handle_response_error(status_code, body)

  @spec document_headers(partition_key :: binary()) :: list({binary(), binary()})
  defp document_headers(partition_key) do
    [
      {"x-ms-documentdb-is-upsert", "True"},
      {"x-ms-documentdb-partitionkey", "[\"#{partition_key}\"]"}
    ]
  end

  @spec document_query_headers(partition_key :: binary() | nil) :: list({binary(), binary()})
  defp document_query_headers(partition_key \\ nil)

  defp document_query_headers(nil) do
    [
      {"x-ms-documentdb-isquery", "True"},
      {"Content-Type", "application/query+json"}
    ]
  end

  defp document_query_headers(partition_key) do
    [{"x-ms-documentdb-partitionkey", "[\"#{partition_key}\"]"} | document_query_headers()]
  end

  @spec document_query_cross_partition_headers(max_item_count :: non_neg_integer()) ::
          list({binary(), binary()})
  defp document_query_cross_partition_headers(max_item_count \\ 100) do
    [
      {"x-ms-max-item-count", "#{max_item_count}"},
      {"x-ms-documentdb-query-enablecrosspartition", "True"}
    ]
  end
end
