defmodule Cosmox.HelpersTest do
  @moduledoc """
  Tests for the helpers methods.
  """

  use ExUnit.Case

  alias Cosmox.Helpers.DateHelpers

  test "The helper method successfully convert a NaiveDateTime to RFC7235 convention" do
    date = ~N[2022-01-01 23:00:00]

    assert "sat, 01 jan 2022 23:00:00 gmt" ==
             DateHelpers.convert_naivedatetime_to_rfc_7231(date)
  end
end
