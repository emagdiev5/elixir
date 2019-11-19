defmodule KVstoreTest do
    use ExUnit.Case
    @host "http://localhost:888/"

    test "can start new process" do
        {message, _pid} = KVstore.Storage.start_link
        assert message == :ok, "can not start new process"
    end

    test "can create record" do
        make_request("create?key=createdKey&value=newvalue&ttl=10")
        :timer.sleep(5000)
        assert get_from_db("createdKey") != [], "record is not created"
    end

    test "can read record" do
        make_request("create?key=readkey&value=newvalue&ttl=10")

        {:ok, {_response, _headers, body}} = make_request("read?key=readkey")
        IO.puts(body)
        assert body == '{"readkey", "newvalue"}', "record is not readable"
    end

    test "read non existant key" do
        {:ok, {_response, _headers, body}} = make_request("read?key=IDontExist")
        assert body == '"no record found"', "non existant key not catched"
    end

    test "can delete record" do
        make_request("create?key=createdKey&value=newvalue&ttl=10")
        make_request("delete?key=createdKey")
    
        assert get_from_db("createdKey") != [], "record is not deleted"
    end

    test "can update record" do
        make_request("update?key=newKey&value=newvalue&ttl=10")

        assert get_from_db("newKey") != [], "record is not updated"
    end

    test "record deleted after ttl=10 seconds" do
        make_request("create?key=tensec&value=newvalue&ttl=10")

        :timer.sleep(11000)
        assert get_from_db("tensec") == [], "11 seconds passed, record not deleted"
    end

    test "incorrect url" do
        {:ok, {_response, _headers, body}} = make_request("unknown?key=unknownkey")
        assert body == 'Oops!', "unknown request not checked"
    end

    defp make_request(query_string) do
        url = String.to_charlist(@host <> query_string)
        :httpc.request(url)
    end

    defp get_from_db(key) do
        :dets.open_file(:disc_storage, [type: :set])
        record = :dets.lookup(:disc_storage, key)
        :dets.close(:disc_storage)
        record
    end
end