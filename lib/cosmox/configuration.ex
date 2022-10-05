defmodule Cosmox.Configuration do
  @moduledoc """
  Gets the configuration values from the configuration files.
  The configuration will be built in at compile time.
  """

  require Logger

  @typedoc """
  Defines the database throughput mode.
  :none - THe database throughput will be automatically defined.
  {:fixed, throughput} - The database throughput will be fixed to the given value
    for every collection.
  {:autopilot, max_throughput} - The database throughput will be automatically
    defined by the system, but it will not exceed the given value.
  """
  @type database_throughput_mode() ::
          :none
          | {:fixed, non_neg_integer()}
          | {:autopilot, non_neg_integer()}

  @doc """
  Gets the CosmosDB database host.
  """
  @spec get_cosmos_db_host() :: binary()
  def get_cosmos_db_host do
    get_configuration_value(:cosmos_db_host, "COSMOS_DB_HOST")
  end

  @doc """
  Gets the CosmosDB database primary key.
  """
  @spec get_cosmos_db_key() :: binary()
  def get_cosmos_db_key do
    get_configuration_value(:cosmos_db_key, "COSMOS_DB_KEY")
  end

  @doc """
  Gets the number of concurrent clients to call CosmosDB REST API.
  """
  @spec get_http_client_pool_size() :: non_neg_integer()
  def get_http_client_pool_size do
    get_configuration_value(:cosmos_db_pool_size, "COSMOS_DB_POOL_SIZE", 30)
  end

  @spec get_configuration_value(atom(), binary(), binary() | integer() | nil) ::
          binary() | integer() | nil
  defp get_configuration_value(key, env_name, default \\ nil)

  defp get_configuration_value(key, env_name, default) do
    case Application.get_env(:cosmox, key) do
      value when not is_nil(value) ->
        value

      _ ->
        # Trying to retrieve the environment variable from system
        case {System.get_env(env_name), default} do
          {value, _} when not is_nil(value) ->
            value

          {_, d} when not is_nil(d) ->
            d

          _ ->
            raise "Configuration #{env_name}"
        end
    end
  end

  @doc """
  Helper to get the db configuration.
  """
  @spec get_cosmos_db_config() :: {binary(), binary()}
  def get_cosmos_db_config do
    cosmos_db_host = get_cosmos_db_host()
    cosmos_db_key = get_cosmos_db_key()

    {cosmos_db_host, cosmos_db_key}
  end

  @doc """
  Defines the default resource creation API headers.
  """
  @spec resource_creation_headers(database_throughput_mode()) ::
          list({binary(), binary()})
  def resource_creation_headers({:fixed, throughput}),
    do: [{"x-ms-offer-throughput", "#{throughput}"}]

  def resource_creation_headers({:autopilot, max_throughput}),
    do: [{"x-ms-cosmos-offer-autopilot-settings", "{\"maxThroughput\": \"#{max_throughput}\"}"}]

  def resource_creation_headers(_),
    do: []
end
