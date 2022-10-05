defmodule Cosmox.ConfigurationTest do
  use ExUnit.Case

  alias Cosmox.Configuration

  setup do
    database_host =
      System.get_env("COSMOS_DB_HOST") ||
        "http://localhost:5025"

    database_key = System.get_env("COSMOS_DB_KEY")

    [
      database_host: database_host,
      database_key: database_key
    ]
  end

  test "The configuration method should get the right host configuration", %{
    database_host: database_host
  } do
    host = Configuration.get_cosmos_db_host()
    assert host == database_host
  end

  test "The configuration method should get the right key configuration", %{
    database_key: database_key
  } do
    key = Configuration.get_cosmos_db_key()

    assert key == database_key
  end

  test "The configuration method should get the right connection pool count configuration" do
    host = Configuration.get_http_client_pool_size()
    assert host == 10
  end
end
