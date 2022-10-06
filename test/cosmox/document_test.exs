defmodule Cosmox.DocumentTest do
  @moduledoc false

  use ExUnit.Case

  alias Cosmox.Container
  alias Cosmox.Database
  alias Cosmox.Document
  alias Cosmox.Structs.DocumentInfo
  alias Cosmox.Structs.Tests.Person

  defp cleanup do
    database_id = "test_db"
    container_id = "test_container"

    Database.delete_database(database_id)
    Container.delete_container(database_id, container_id)

    {database_id, container_id}
  end

  setup do
    {database_id, container_id} = cleanup()

    Database.create_database(database_id, {:fixed, 400})
    Container.create_container(database_id, container_id, {:fixed, 400})

    # on_exit(&cleanup/0)

    [database_id: database_id, container_id: container_id]
  end

  test "The Document should be inserted successfully into the container", %{
    database_id: database_id,
    container_id: container_id
  } do
    partition_key = "some_pk"
    person_id = "1"

    person = %Person{
      id: person_id,
      pk: partition_key,
      name: "Some Name",
      surname: "Some Surname",
      age: 40
    }

    assert {:ok, %DocumentInfo{id: ^person_id, pk: ^partition_key}} =
             Document.create_document(database_id, container_id, person)

    assert {:ok, [%Person{id: ^person_id}]} =
             Document.list_documents(database_id, container_id, partition_key, Person)
  end

  test "The Document should be inserted successfully into the container, and parsed as the given struct",
       %{
         database_id: database_id,
         container_id: container_id
       } do
    partition_key = "some_pk"
    person_id = "1"

    person = %Person{
      id: person_id,
      pk: partition_key,
      name: "Some Name",
      surname: "Some Surname",
      age: 40
    }

    assert {:ok, %Person{id: ^person_id, pk: ^partition_key}} =
             Document.create_document(database_id, container_id, person, Person)

    assert {:ok, [%Person{id: ^person_id}]} =
             Document.list_documents(database_id, container_id, partition_key, Person)
  end

  test "The Documents should be listed successfully after having being inserted.", %{
    database_id: database_id,
    container_id: container_id
  } do
    partition_key = "some_pk"
    person_id = "1"

    person = %Person{
      id: person_id,
      pk: partition_key,
      name: "Some Name",
      surname: "Some Surname",
      age: 40
    }

    assert {:ok, %DocumentInfo{id: ^person_id, pk: ^partition_key}} =
             Document.create_document(database_id, container_id, person)

    assert {:ok, [%Person{id: ^person_id}]} =
             Document.list_documents(database_id, container_id, partition_key, Person)

    assert {:ok, [%{"id" => ^person_id}]} =
             Document.list_documents(database_id, container_id, partition_key)
  end

  test "The singular Document should be retrieved successfully after having being inserted.", %{
    database_id: database_id,
    container_id: container_id
  } do
    partition_key = "some_pk"
    person_id = "1"

    person = %Person{
      id: person_id,
      pk: partition_key,
      name: "Some Name",
      surname: "Some Surname",
      age: 40
    }

    assert {:ok, %DocumentInfo{id: ^person_id, pk: ^partition_key}} =
             Document.create_document(database_id, container_id, person)

    assert {:ok, %Person{id: ^person_id}} =
             Document.get_document(database_id, container_id, person_id, partition_key, Person)

    assert {:ok, %{"id" => ^person_id}} =
             Document.get_document(database_id, container_id, person_id, partition_key)
  end

  test "The Document should be updated correctly using the replace_document function.", %{
    database_id: database_id,
    container_id: container_id
  } do
    partition_key = "some_pk"
    person_id = "1"
    person_name = "Some Name"
    person_modified_name = "Some Other Name"

    person = %Person{
      id: person_id,
      pk: partition_key,
      name: person_name,
      surname: "Some Surname",
      age: 40
    }

    assert {:ok, %DocumentInfo{id: ^person_id, pk: ^partition_key}} =
             Document.create_document(database_id, container_id, person)

    assert {:ok, %Person{id: ^person_id, name: ^person_name}} =
             Document.get_document(database_id, container_id, person_id, partition_key, Person)

    person =
      person
      |> Map.put(:name, person_modified_name)

    assert {:ok, %{id: ^person_id, name: ^person_modified_name}} =
             Document.replace_document(database_id, container_id, person_id, person, Person)

    assert {:ok, %{"id" => ^person_id, "name" => ^person_modified_name}} =
             Document.get_document(database_id, container_id, person_id, partition_key)

    assert {:ok, %Person{id: ^person_id, name: ^person_modified_name}} =
             Document.get_document(database_id, container_id, person_id, partition_key, Person)
  end

  test "The Document should be patched correctly using the patch_document function.", %{
    database_id: database_id,
    container_id: container_id
  } do
    partition_key = "some_pk"
    person_id = "1"
    person_name = "Some Name"
    person_modified_name = "Some Other Name"
    person_modified_age = 55

    person = %Person{
      id: person_id,
      pk: partition_key,
      name: person_name,
      surname: "Some Surname",
      age: 40
    }

    assert {:ok, %DocumentInfo{id: ^person_id, pk: ^partition_key}} =
             Document.create_document(database_id, container_id, person)

    assert {:ok, %Person{id: ^person_id, name: ^person_name}} =
             Document.get_document(database_id, container_id, person_id, partition_key, Person)

    assert {:ok, %{id: ^person_id, name: ^person_modified_name}} =
             Document.patch_document(
               database_id,
               container_id,
               person_id,
               partition_key,
               {
                 "name",
                 person_modified_name
               },
               Person
             )

    assert {:ok, %{"id" => ^person_id, "name" => ^person_modified_name}} =
             Document.get_document(database_id, container_id, person_id, partition_key)

    assert {:ok, %Person{id: ^person_id, name: ^person_modified_name}} =
             Document.get_document(database_id, container_id, person_id, partition_key, Person)

    assert {:ok, %{id: ^person_id, name: ^person_modified_name}} =
             Document.patch_document(
               database_id,
               container_id,
               person_id,
               partition_key,
               {
                 "age",
                 person_modified_age
               },
               Person
             )

    assert {:ok, %{"id" => ^person_id, "age" => ^person_modified_age}} =
             Document.get_document(database_id, container_id, person_id, partition_key)

    assert {:ok, %Person{id: ^person_id, age: ^person_modified_age}} =
             Document.get_document(database_id, container_id, person_id, partition_key, Person)
  end

  test "The Document should be deleted correctly using the delete_document function.", %{
    database_id: database_id,
    container_id: container_id
  } do
    partition_key = "some_pk"
    person_id = "1"
    person_name = "Some Name"

    person = %Person{
      id: person_id,
      pk: partition_key,
      name: person_name,
      surname: "Some Surname",
      age: 40
    }

    assert {:ok, %DocumentInfo{id: ^person_id, pk: ^partition_key}} =
             Document.create_document(database_id, container_id, person)

    assert {:ok, %Person{id: ^person_id, name: ^person_name}} =
             Document.get_document(database_id, container_id, person_id, partition_key, Person)

    assert :ok = Document.delete_document(database_id, container_id, person_id, partition_key)

    assert {:error, _} =
             Document.get_document(database_id, container_id, person_id, partition_key)
  end

  defp fill_database_with_people(database_id, container_id) do
    people = [
      %Person{
        id: "1",
        pk: "pk1",
        name: "Ludwig",
        surname: "Fowler",
        age: 55
      },
      %Person{
        id: "2",
        pk: "pk1",
        name: "Paul",
        surname: "Right",
        age: 49
      },
      %Person{
        id: "3",
        pk: "pk2",
        name: "Adam",
        surname: "Wick",
        age: 24
      },
      %Person{
        id: "4",
        pk: "pk2",
        name: "Peter",
        surname: "Ryder",
        age: 15
      }
    ]

    people
    |> Enum.each(fn p -> Document.create_document(database_id, container_id, p) end)
  end

  test "The Documents should be retrieved correctly through the SQL-like query.", %{
    database_id: database_id,
    container_id: container_id
  } do
    fill_database_with_people(database_id, container_id)

    assert {:ok, people} =
             Document.query_documents(
               database_id,
               container_id,
               "pk1",
               {
                 "SELECT * FROM c WHERE c.age > @p1",
                 [
                   {"@p1", 50}
                 ]
               }
             )

    assert 1 == people |> Enum.count()
  end

  test "The Documents should fail if the wrong query is sent.", %{
    database_id: database_id,
    container_id: container_id
  } do
    fill_database_with_people(database_id, container_id)

    assert {:error, _} =
             Document.query_documents(
               database_id,
               container_id,
               "pk1",
               {
                 "SELECT * FROM c WHERE age > @p1",
                 [
                   {"@p1", 50}
                 ]
               }
             )
  end

  test "The Documents should be retrieved correctly through the cross-partition SQL-like query.",
       %{
         database_id: database_id,
         container_id: container_id
       } do
    fill_database_with_people(database_id, container_id)

    assert {:ok, people} =
             Document.query_documents_cross_partition(
               database_id,
               container_id,
               {
                 "SELECT * FROM c WHERE c.age < @p1",
                 [
                   {"@p1", 50}
                 ]
               }
             )

    assert 3 == people |> Enum.count()
  end
end
