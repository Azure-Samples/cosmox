[![Build](https://github.com/Azure-Samples/Cosmox/actions/workflows/compilation.yml/badge.svg)](https://github.com/Azure-Samples/Cosmox/actions/workflows/compilation.yml)

# Project

The project aims at providing an Elixir client for the Cosmos DB SQL REST API. Although the library
provides a map for every functionality of the SQL REST API, there are no optimisation 
available for handling the collection.

#### Special mention

This project took huge inspiration from [this project](https://github.com/jeramyRR/cosmos_db_ex).

### Usage

The library acts as a client for the four different entities available in Cosmos DB, each of which
has its own module:

- `Cosmox.Database`: provides functions to create, modify and delete a database in 
an instance of Cosmos DB.
- `Cosmox.Container`: provides functions to create, modify and delete containers in a database.
- `Cosmox.Document`: provides functions to create, patch, modify, delete and query documents in
a container, both in and among different partitions. There is currently no check available for
queries that spans more than one partition.
- `Cosmox.StoredProcedure`: provides a way to manage stored procedures in Cosmos DB.

The library has connection pooling baked in already, and it uses [Nestru](https://github.com/IvanRublev/Nestru)
to generate `struct`s from maps, but its usage is completely optional, and to activate it
it will be necessary to pass the `struct` to deserialise the response to as the last 
parameters in the `Cosmox.Document` functions.

### Configuration

Cosmox requires defining the Cosmos DB instance URL and the access key. These information can
be found in the Azure Portal under the **Keys** tab.

Cosmox uses [Finch](https://github.com/sneako/finch) to handle the connection pooling. It is 
automatically configured, but the configuration can be overridden by specifying the 
`cosmos_db_pool_size` configuration.

This is an example of the configuration:

```elixir
config :cosmox,
  cosmos_db_host: "<substitute-cosmos-db-host-here>",
  cosmos_db_key: "<substitute-cosmos-db-key-here>",
  cosmos_db_pool_size: <substitute-with-connection-pool-size>
```

**Note**: the Cosmos DB key grants access to the database, so it's highly recommended to store 
the `cosmos_db_key` configuration in a safe way.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
