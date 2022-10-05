defmodule Cosmox.ContainerTest do
  @moduledoc """
  A cllection of tests for the Container API client.
  """

  use ExUnit.Case

  alias Cosmox.Application
  alias Cosmox.Container
  alias Cosmox.Database

  @database_id "test_db"
  @container_id "test_container"

  def cleanup do
    # Cleaning all the resources
    Database.delete_database(@database_id)
  end

  setup_all do
    # Starting the Application
    Application.start(nil, nil)
    cleanup()
    :ok
  end

  setup do
    Database.create_database(@database_id, {:fixed, 400})
    on_exit(&cleanup/0)
  end

  describe "The container API " do
    test "correctly create a collection" do
      assert {:ok, %{id: @container_id}} = Container.create_container(@database_id, @container_id)

      assert {:ok, %{id: @container_id}} = Container.get_container(@database_id, @container_id)

      assert :ok = Container.delete_container(@database_id, @container_id)

      assert {:error, _} = Container.get_container(@database_id, @container_id)
    end

    test "correctly returns the partition key ranges available for the collection" do
      assert {:ok, _} = Container.create_container(@database_id, @container_id)

      assert {:ok, result} = Container.get_container_partition_keys(@database_id, @container_id)
      assert not is_nil(result.partition_key_ranges)

      Container.delete_container(@database_id, @container_id)
    end
  end
end
