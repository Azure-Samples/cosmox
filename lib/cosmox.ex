defmodule Cosmox do
  @moduledoc """
  Collection of example functions to represent how to use the Cosmox library.
  """

  alias Cosmox.Response.ErrorMessage
  alias Cosmox.Structs.Collection
  alias Cosmox.Helpers.ApiHelpers
  alias Cosmox.Helpers.DeserializationHelpers
  alias Cosmox.RestClient
  alias Cosmox.Database
  alias Cosmox.Container
  alias Cosmox.Document

  def deserialize() do
    map = %{"test" => "test"}
    encoded_map = Jason.encode!(map)

    case DeserializationHelpers.deserialize(encoded_map) do
      {:ok, result} ->
        IO.inspect(result)

      {:error, %ErrorMessage{errors: errors}} ->
        IO.inspect(errors)
    end
  end

  def call() do
    case ApiHelpers.call(:dbs, :get, "", "") do
      {:ok, response} -> response
      error = {:error, %ErrorMessage{}} -> error
    end
  end

  def call_and_parse() do
    response = ApiHelpers.call(:dbs, :get, "", "")
    case response |> RestClient.try_decode_response(Collection) do
      {:ok, response} -> response
      error = {:error, %ErrorMessage{}} -> error
    end
  end

  def create_database() do
    case Database.create_database("test_database") do
      {:ok, _} ->
        IO.puts("Database created")

      {:error, %ErrorMessage{errors: messages}} ->
        IO.puts("Error creating database: #{messages}")
    end
  end

  def create_container() do
    case Container.create_container("test_database", "test_container") do
      {:ok, _} ->
        IO.puts("Container created")

      {:error, %ErrorMessage{errors: messages}} ->
        IO.puts("Error creating container: #{messages}")
    end
  end

  def create_document() do
    case Document.create_document("test_database", "test_container", %{
      "name" => "John",
      "age" => 30,
      "id" => "1",
      "pk" => "pk"
    }, nil) do
      {:ok, _} ->
        IO.puts("Document created")

      {:error, %ErrorMessage{errors: messages}} ->
        IO.puts("Error creating document: #{messages}")
    end
  end

  def query_documents() do
    case Document.query_documents("test_database", "test_container", "pk", {"SELECT * FROM c", []}) do
      {:ok, _} ->
        IO.puts("Documents queried")

      {:error, %ErrorMessage{errors: messages}} ->
        IO.puts("Error querying documents: #{messages}")
    end
  end

end
