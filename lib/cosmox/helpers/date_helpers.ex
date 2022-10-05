defmodule Cosmox.Helpers.DateHelpers do
  @moduledoc """
  Offers a series of helper functions to handle the data.
  """

  @doc """
  Gives a representation of a NaiveDateTime date in RFC 7231 Date/Time format.
  """
  @spec convert_naivedatetime_to_rfc_7231(date :: NaiveDateTime.t()) :: binary()
  def convert_naivedatetime_to_rfc_7231(date) do
    date
    |> Timex.Timezone.convert("GMT")
    |> Timex.format!("%a, %d %b %Y %H:%M:%S GMT", :strftime)
    |> String.downcase()
  end

  @doc """
  Returns the current date as a RFC7231 formatted string.
  """
  @spec now_rfc_7231() :: binary()
  def now_rfc_7231 do
    NaiveDateTime.utc_now()
    |> convert_naivedatetime_to_rfc_7231()
  end
end
