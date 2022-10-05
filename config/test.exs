import Config

cosmos_db_host =
  System.get_env("COSMOS_DB_HOST") ||
    ""

cosmos_db_key =
  System.get_env("COSMOS_DB_KEY") ||
    ""

config :cosmox,
  cosmos_db_host: cosmos_db_host,
  cosmos_db_key: cosmos_db_key,
  cosmos_db_pool_size: 10
