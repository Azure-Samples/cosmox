defmodule Cosmox.AuthTest do
  use ExUnit.Case

  alias Cosmox.Auth

  test "The authorization filter correctly returns an error when the key is not encoded in Base64" do
    key = "some-key"

    generated_key =
      Auth.generate_master_key_authorization_signature(
        "POST",
        :dbs,
        "https://localhost:8081",
        NaiveDateTime.utc_now(),
        key
      )

    assert {:error, _} = generated_key
  end

  test "The authorization filter correctly generate the token for the request header" do
    encoded_key =
      "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="

    execution_date = ~N[2022-08-22 22:24:21]

    generated_key =
      Auth.generate_master_key_authorization_signature(
        "POST",
        :dbs,
        "",
        execution_date,
        encoded_key
      )

    assert {:ok,
            "type%3Dmaster%26ver%3D1.0%26sig%3DTw%2BW5a9JDcAppFl8qNJFt0KX2oj3zX9yftSkKB40Phc%3D"} =
             generated_key
  end

  test "The authorization filter for collections generate the correct token for the request header" do
    encoded_key =
      "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="

    execution_date = ~N[2022-08-26 23:19:39]

    generated_key =
      Auth.generate_master_key_authorization_signature(
        "POST",
        :colls,
        "dbs/testdb",
        execution_date,
        encoded_key
      )

    assert {:ok,
            "type%3Dmaster%26ver%3D1.0%26sig%3DTnhCeEDoy0DUNoQ98kEdn4CPn2AaVI8zRhLTvFtr8dA%3D"} =
             generated_key
  end
end
