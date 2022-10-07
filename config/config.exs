import Config

config :cosmox,
  cosmos_db_host: "test",
  cosmos_db_key: "test"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
