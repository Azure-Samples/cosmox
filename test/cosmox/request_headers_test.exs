defmodule Cosmox.RequestHeadersTest do
  @moduledoc false

  use ExUnit.Case

  alias Cosmox.Helpers.DateHelpers
  alias Cosmox.Requests.RequestHeaders

  @exception_message "Authorization string and Request date should not be null"

  test "Sending blank authorization string should trigger an error" do
    request_date = NaiveDateTime.utc_now()

    assert_raise(RuntimeError, @exception_message, fn ->
      RequestHeaders.get_default_headers(nil, request_date)
    end)
  end

  test "Sending blank command date should trigger an error" do
    authorization_string = "some_auth_string"

    assert_raise(RuntimeError, @exception_message, fn ->
      RequestHeaders.get_default_headers(authorization_string, nil)
    end)
  end

  test "The default request headers method should return the correct headers collection" do
    authorization_string = "some_auth_string"
    request_date = NaiveDateTime.utc_now()
    headers = RequestHeaders.get_default_headers(authorization_string, request_date)

    assert not is_nil(headers)
    assert 4 <= headers |> Enum.count()
    assert authorization_string == headers |> get_header_value!("authorization")

    assert request_date |> DateHelpers.convert_naivedatetime_to_rfc_7231() ==
             headers |> get_header_value!("x-ms-date")

    assert RequestHeaders.get_current_api_version() ==
             headers |> get_header_value!("x-ms-version")

    assert "application/json" == headers |> get_header_value!("Accept")
  end

  defp get_header_value!(headers, key) do
    {_, value} =
      headers
      |> Enum.find(fn
        {^key, _} -> true
        _ -> false
      end)

    value
  end
end
