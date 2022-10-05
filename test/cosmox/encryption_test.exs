defmodule EncryptionTest do
  use ExUnit.Case

  alias Cosmox.Encryption

  test "The get_encrypted_payload method will generate a correct key" do
    payload = "some payload"
    key = "some_key"

    encoded_key = Base.encode64(key)
    {:ok, result} = Encryption.get_encrypted_payload(payload, encoded_key)

    assert "SQaGNixlo1a6O0k0CoiM611ONh1MoewhTDfD9r9LEyE=" == result
    assert {:ok, decoded_result} = Base.decode64(result)
    assert is_binary(decoded_result)
  end

  test "The get_encrypted_payload method with actual payload will generate a correct key" do
    payload = "post\ndbs\n\nmon, 22 aug 2022 22:24:21 gmt\n\n"

    encoded_key =
      "C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="

    {:ok, result} = Encryption.get_encrypted_payload(payload, encoded_key)

    assert "Tw+W5a9JDcAppFl8qNJFt0KX2oj3zX9yftSkKB40Phc=" == result
    assert {:ok, decoded_result} = Base.decode64(result)
    assert is_binary(decoded_result)
  end

  test "The get_encrypted_payload method will return an error when a wrong key is given" do
    payload = "some payload"
    key = "some_key"

    result = Encryption.get_encrypted_payload(payload, key)
    assert {:error, _} = result
  end
end
