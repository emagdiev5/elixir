defmodule KVstoreTest do
    use ExUnit.Case

    test "can create record" do
        url = String.to_charlist("http://localhost:888/create?key=newkey&value=newvalue&ttl=10")
        :httpc.request(url)
        record = :dets.lookup(:disc_storage, "newkey")
        assert record != nil, "record is not created"
    end

    test "record deleted after 10 seconds" do
        url = String.to_charlist("http://localhost:888/create?key=newkey&value=newvalue&ttl=10")
        :httpc.request(url)
        record = :dets.lookup(:disc_storage, "newkey")
        :timer.sleep(11000)
        assert record != nil, "11 seconds passed, record not deleted"
    end
end