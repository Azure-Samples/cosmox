defmodule Cosmox.DeserializationTest do
  @moduledoc """
  Tests the various deserialisation commands.
  """

  use ExUnit.Case

  alias Cosmox.Helpers.DeserializationHelpers

  alias Cosmox.Structs.{
    Collection,
    Database,
    DatabaseList,
    DocumentInfo,
    DocumentList,
    PartitionKeyRangeResponse
  }

  alias Cosmox.Structs.Tests.Person

  test "The Database object deserialisation should succeed" do
    map = %{
      "id" => "id",
      "_rid" => "_rid",
      "_self" => "_self",
      "_etag" => "_etag",
      "_colls" => "_colls",
      "_users" => "_users",
      "_ts" => "_ts"
    }

    serialized_map = Jason.encode!(map)

    assert {:ok, deserialization_result} =
             DeserializationHelpers.deserialize(serialized_map, Database)

    assert %Database{
             id: "id",
             _rid: "_rid",
             _self: "_self",
             _etag: "_etag",
             _colls: "_colls",
             _users: "_users",
             _ts: "_ts"
           } = deserialization_result
  end

  test "The DatabaseList object deserialisation should succeed" do
    database_map = %{
      "id" => "id",
      "_rid" => "_rid",
      "_self" => "_self",
      "_etag" => "_etag",
      "_colls" => "_colls",
      "_users" => "_users",
      "_ts" => "_ts"
    }

    map = %{
      "Databases" => [database_map]
    }

    serialized_map = Jason.encode!(map)

    {:ok, deserialization_result} =
      DeserializationHelpers.deserialize(serialized_map, DatabaseList)

    assert %DatabaseList{
             databases: [
               %Database{
                 id: "id",
                 _rid: "_rid",
                 _self: "_self",
                 _etag: "_etag",
                 _colls: "_colls",
                 _users: "_users",
                 _ts: "_ts"
               }
             ]
           } = deserialization_result
  end

  test "The Collection object deserialization should succeed" do
    serialized_collection =
      "{\"id\":\"test_collection\",\"indexingPolicy\":{\"indexingMode\":\"consistent\",\"automatic\":true,\"includedPaths\":[{\"path\":\"\\/*\"}],\"excludedPaths\":[{\"path\":\"\\/\\\"_etag\\\"\\/?\"}]},\"partitionKey\":{\"paths\":[\"\\/pk\"],\"kind\":\"Hash\",\"version\":2},\"conflictResolutionPolicy\":{\"mode\":\"LastWriterWins\",\"conflictResolutionPath\":\"\\/_ts\",\"conflictResolutionProcedure\":\"\"},\"geospatialConfig\":{\"type\":\"Geography\"},\"_rid\":\"kugiALz-+-4=\",\"_ts\":1661590736,\"_self\":\"dbs\\/kugiAA==\\/colls\\/kugiALz-+-4=\\/\",\"_etag\":\"\\\"00000000-0000-0000-b9f3-3d96121201d8\\\"\",\"_docs\":\"docs\\/\",\"_sprocs\":\"sprocs\\/\",\"_triggers\":\"triggers\\/\",\"_udfs\":\"udfs\\/\",\"_conflicts\":\"conflicts\\/\"}"

    assert {:ok, deserialized} =
             DeserializationHelpers.deserialize(serialized_collection, Collection)

    assert "test_collection" == deserialized.id
  end

  test "The collection partition keys deserialization should succeed" do
    serialized_object =
      "{\"_rid\":\"e4AiAMaW60A=\",\"PartitionKeyRanges\":[{\"_rid\":\"e4AiAMaW60ACAAAAAAAAUA==\",\"id\":\"0\",\"_etag\":\"\\\"00000000-0000-0000-ba15-010e51d801d8\\\"\",\"minInclusive\":\"\",\"maxExclusive\":\"FF\",\"ridPrefix\":0,\"_self\":\"dbs\\/e4AiAA==\\/colls\\/e4AiAMaW60A=\\/pkranges\\/e4AiAMaW60ACAAAAAAAAUA==\\/\",\"throughputFraction\":1,\"status\":\"online\",\"parents\":[],\"_ts\":1661605238}],\"_count\":1}"

    assert {:ok, deserialized} =
             DeserializationHelpers.deserialize(serialized_object, PartitionKeyRangeResponse)

    assert not is_nil(deserialized.partition_key_ranges)
  end

  test "The document information deserialization should succeed" do
    serialized_object =
      "{\"age\":39,\"id\":\"1\",\"name\":\"Alfred\",\"pk\":\"some_pk\",\"surname\":\"Wilson\",\"_rid\":\"+N0xAOHG090FAAAAAAAAAA==\",\"_self\":\"dbs\\/+N0xAA==\\/colls\\/+N0xAOHG090=\\/docs\\/+N0xAOHG090FAAAAAAAAAA==\\/\",\"_etag\":\"\\\"00000000-0000-0000-ba23-1e8d2e3101d8\\\"\",\"_attachments\":\"attachments\\/\",\"_ts\":1661611300}"

    assert {:ok, deserialized} =
             DeserializationHelpers.deserialize(serialized_object, DocumentInfo)

    assert not is_nil(deserialized.pk)

    assert %DocumentInfo{
             pk: "some_pk",
             _rid: "+N0xAOHG090FAAAAAAAAAA==",
             _self: "dbs/+N0xAA==/colls/+N0xAOHG090=/docs/+N0xAOHG090FAAAAAAAAAA==/",
             _etag: "\"00000000-0000-0000-ba23-1e8d2e3101d8\"",
             _attachments: "attachments/",
             _ts: 1_661_611_300
           } = deserialized
  end

  test "The DocumentList should deserialize the list of document given the struct" do
    document_list = %DocumentList{
      documents: [
        %{
          "_attachments" => "attachments/",
          "_etag" => "\"00000000-0000-0000-ba48-9f7dbde001d8\"",
          "_rid" => "L64oALLPIhkBAAAAAAAAAA==",
          "_self" => "dbs/L64oAA==/colls/L64oALLPIhk=/docs/L64oALLPIhkBAAAAAAAAAA==/",
          "_ts" => 1_661_627_408,
          "age" => 40,
          "id" => "1",
          "name" => "Some Name",
          "pk" => "some_pk",
          "surname" => "Some Surname"
        }
      ]
    }

    DocumentList.try_deserialize_documents(document_list, Person)
  end
end
