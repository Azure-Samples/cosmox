defmodule Cosmox.StoredProcedureTest do
  @moduledoc false

  use ExUnit.Case

  alias Cosmox.Container
  alias Cosmox.Database
  alias Cosmox.StoredProcedure, as: SP
  alias Cosmox.Structs.StoredProcedure

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

    on_exit(&cleanup/0)

    [database_id: database_id, container_id: container_id]
  end

  test "The stored procedure should be created on the database.", %{
    database_id: database_id,
    container_id: container_id
  } do
    stored_procedure = %StoredProcedure{
      name: "test_procedure",
      body: """
      function () {
        var context = getContext();
        var response = context.getResponse();
        response.setBody(\""Hello, World\"");
      }
      """
    }

    assert :ok = SP.create_stored_procedure(database_id, container_id, stored_procedure)
  end

  test "The stored procedure should be deleted on the database.", %{
    database_id: database_id,
    container_id: container_id
  } do
    %{name: sproc_name} =
      stored_procedure = %StoredProcedure{
        name: "test_procedure",
        body: """
        function () {
          var context = getContext();
          var response = context.getResponse();
          response.setBody(\""Hello, World\"");
        }
        """
      }

    assert :ok = SP.create_stored_procedure(database_id, container_id, stored_procedure)

    assert :ok = SP.delete_stored_procedure(database_id, container_id, sproc_name)
  end
end
