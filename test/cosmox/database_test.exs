defmodule Cosmox.DatabaseTest do
  @moduledoc """
  Tests for the database API.
  """

  use ExUnit.Case

  require Logger

  alias Cosmox.Database
  alias Cosmox.Response.ErrorMessage
  alias Cosmox.Structs.Database, as: DbStruct
  alias Cosmox.Structs.DatabaseList

  defp cleanup do
    database_id = "test_db"
    second_database_id = "second_test_id"

    Database.delete_database(database_id)
    Database.delete_database(second_database_id)

    {database_id, second_database_id}
  end

  setup do
    {database_id, second_database_id} = cleanup()
    on_exit(&cleanup/0)
    [database_id: database_id, second_database_id: second_database_id]
  end

  describe "The database API" do
    test "successfully create the database, search for it, and then delete it", %{
      database_id: database_id
    } do
      assert {:ok, _} = Database.create_database(database_id, {:fixed, 400})

      assert {:ok, databases} = Database.list_databases()

      databases = %DatabaseList{
        databases:
          databases.databases
          |> Enum.filter(fn
            %{id: ^database_id} -> true
            _ -> false
          end)
      }

      assert 1 == databases.databases |> Enum.count()

      assert %DatabaseList{
               databases: [
                 %DbStruct{
                   id: ^database_id
                 }
               ]
             } = databases

      assert {:ok, database} = Database.get_database(database_id)

      assert %DbStruct{
               id: ^database_id
             } = database

      assert :ok = Database.delete_database(database_id)

      assert {:ok, databases} = Database.list_databases()

      assert 0 ==
               databases.databases
               |> Enum.filter(fn
                 %{database_id: ^database_id} -> true
                 _ -> false
               end)
               |> Enum.count()

      error_not_found = Cosmox.RestClient.get_error_not_found_message()

      assert {:error, %ErrorMessage{errors: [^error_not_found]}} =
               Database.get_database(database_id)

      cleanup()
    end

    test "returns an error when a DB cannot be created with the same name of an existing one", %{
      database_id: database_id
    } do
      assert {:ok, _} = Database.create_database(database_id, {:fixed, 400})

      already_existent_error = Cosmox.RestClient.get_error_naming_conflict()

      assert {:error, %ErrorMessage{errors: [^already_existent_error]}} =
               Database.create_database(database_id, {:fixed, 400})

      cleanup()
    end

    test "returns two database when two are created", %{
      database_id: database_id,
      second_database_id: second_database_id
    } do
      Database.delete_database(second_database_id)

      assert {:ok, _} = Database.create_database(database_id, {:fixed, 400})
      assert {:ok, _} = Database.create_database(second_database_id, {:fixed, 400})

      assert {:ok, response} = Database.list_databases()

      assert 2 ==
               response.databases
               |> Enum.filter(fn
                 %{id: ^database_id} -> true
                 %{id: ^second_database_id} -> true
                 _ -> false
               end)
               |> Enum.count()

      ids =
        response.databases
        |> Enum.map(& &1.id)

      assert 1 == ids |> Enum.count(&(&1 == database_id))
      assert 1 == ids |> Enum.count(&(&1 == second_database_id))

      cleanup()
    end
  end
end
