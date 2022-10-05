defmodule Cosmox.Response.ErrorMessage do
  @moduledoc """
  Represents the error message from a faulty response.
  """

  defstruct errors: []

  @type t() :: %__MODULE__{
          errors: list(binary())
        }

  @doc """
  Tries to get the error JSON object from the error message returned from the REST API.
  """
  @spec extract_errors_from_message(error_message :: binary()) ::
          {:ok, __MODULE__.t()} | {:error, Jason.DecodeError.t()}
  def extract_errors_from_message(error_message) do
    error_message
    |> String.replace("Message: ", "")
    |> String.split("\r\n")
    |> Enum.at(0)
    |> Jason.decode()
  end
end
