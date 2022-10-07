defmodule Cosmox.RestClient do
  @moduledoc """
  Set of helpers to manage request and response management while interfacing with CosmosDB REST API.
  """

  alias Cosmox.Helpers.DeserializationHelpers
  alias Cosmox.Response.ErrorMessage
  alias Finch.Request, as: Req
  alias Finch.Response, as: Res

  @type method() :: :get | :post | :put | :patch | :delete

  @type url() :: String.t() | URI.t()

  @type headers() :: Mint.Types.headers()

  @type body() :: iodata() | {:stream, Enumerable.t()} | nil

  @error_not_found "Object not found"

  @error_naming_conflict "The resource already exist, or there is a name conflict"

  @doc """
  Gets the error message obtained when the object was not found through the API.
  """
  @spec get_error_not_found_message() :: binary()
  def get_error_not_found_message, do: @error_not_found

  @doc """
  Gets the error message when, while creating an object, there is a naming conflict.
  """
  @spec get_error_naming_conflict() :: binary()
  def get_error_naming_conflict, do: @error_naming_conflict

  @doc """
  Perform the request to the CosmosDB REST API.
  Returns a common error that resumes both the client call and the deserialisation error.
  """
  @spec perform_request(
          method :: method(),
          url :: url(),
          headers :: headers(),
          body :: body() | binary() | nil
        ) ::
          {:ok, Res.t()}
          | {:error, ErrorMessage.t()}
  def perform_request(method, url, headers, body \\ nil)

  def perform_request(method, url, headers, body) when not is_nil(body) and not is_binary(body) do
    perform_request(method, url, headers, Jason.encode!(body))
  end

  def perform_request(method, url, headers, body) do
    case finch_wrapper(method, url, headers, body) do
      response = {:ok, _} ->
        response

      {:error, ex} ->
        {:error,
         %{
           errors: [
             "Error while calling the database",
             "#{inspect(ex)}"
           ]
         }}
    end
  end

  @spec finch_wrapper(
          method :: Req.method(),
          url :: Req.url(),
          headers :: Req.headers(),
          body :: Req.body()
        ) ::
          {:ok, Res.t()}
          | {:error, Exception.t()}
  defp finch_wrapper(method, url, headers, body) do
    Finch.build(method, url, headers, body)
    |> Finch.request(Cosmox.Application)
  end

  @doc """
  Hides the response from the caller, preventing it from being leaked outside the scope of the API.
  """
  @spec hide_response(response :: {:ok, Res.t()} | {:error, ErrorMessage.t()}) ::
          :ok
          | {:error, ErrorMessage.t()}
  def hide_response({:ok, _}), do: :ok

  def hide_response(error_response), do: error_response

  @doc """
  Decodes the response body, trying to parse it to the given struct.

  For the list of options for the opts keyword, refer to the method decode_response/3
  """
  @spec try_decode_response(
          response :: {:ok, Res.t()} | {:error, ErrorMessage.t()} | {:error, any()},
          struct :: module(),
          opts :: Keyword.t()
        ) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
  def try_decode_response(response, struct, opts \\ []) do
    case response do
      {:ok, response} ->
        decode_response(response, struct, opts)

      {:error, error = %ErrorMessage{}} ->
        {:error, error}

      {:error, error} ->
        {:error,
         %{
           errors: [
             "Error while calling the database",
             "#{inspect(error)}"
           ]
         }}
    end
  end

  @doc """
  Decodes the response body, trying to parse it to the given struct.

  List of options available through the `opts` parameter:

  - :error_handler: a function that accepts a status code and the body in a binary string form,
    and returns the type ErrorMessage.t()
  """
  @spec decode_response(response :: Res.t(), struct :: module(), list()) ::
          {:ok, term | map()}
          | {:error, ErrorMessage.t()}
  def decode_response(%{status: status, body: body}, struct, opts \\ []) do
    case status do
      n when n < 300 ->
        DeserializationHelpers.deserialize(body, struct)

      _ ->
        case opts |> Keyword.get(:error_handler) do
          nil -> handle_response_error(status, body)
          f -> {:error, f.(status, body)}
        end
    end
  end

  @spec handle_response_error(status :: non_neg_integer(), body :: binary()) ::
          {:error, ErrorMessage.t()}
  def handle_response_error(status, body) do
    case status do
      404 ->
        {:error, %ErrorMessage{errors: [@error_not_found]}}

      409 ->
        {:error, %ErrorMessage{errors: [@error_naming_conflict]}}

      _ ->
        {:error,
         %ErrorMessage{
           errors: [
             "An error occurred while contacting CosmosDB",
             "Response status code: #{inspect(status)}",
             "#{inspect(body)}"
           ]
         }}
    end
  end
end
