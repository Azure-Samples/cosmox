defmodule Cosmox.Application do
  @moduledoc false

  use Application

  alias Cosmox.Configuration

  @impl true
  def start(_type, _args) do
    database_host = Configuration.get_cosmos_db_host()

    children = [
      {
        Finch,
        name: __MODULE__,
        pools: %{
          :default => [size: 10],
          "https://#{database_host}" => [size: 32, count: 8]
        }
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
