defmodule KVstore.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @key   "key"
  @value "value"
  @ttl   "ttl"

  get "/create" do
    conn = fetch_query_params(conn, []) 
    %{ @key => key, @value => value, @ttl => ttl} = conn.params
    {:ok, pid} = KVstore.Storage.start_link
    KVstore.Storage.create(pid, key, value, ttl)
    send_resp(conn, 200, "New record with {'#{key}', '#{value}'} created for #{ttl} seconds")
  end

  get "/update" do
    conn = fetch_query_params(conn, []) 
    %{ @key => key, @value => value, @ttl => ttl} = conn.params
    {:ok, pid} = KVstore.Storage.start_link
    KVstore.Storage.update(pid, key, value, ttl)
    send_resp(conn, 200, "record updated to {'#{key}', '#{value}'}. new expiration time is #{ttl} seconds")
  end

  get "/read" do
    conn = fetch_query_params(conn, []) 
    %{ @key => key } = conn.params
    value = KVstore.Storage.read(key)
    send_resp(conn, 200, "#{inspect value}")
  end

  get "/delete" do
    conn = fetch_query_params(conn, []) 
    %{ @key => key } = conn.params
    send_resp(conn, 200, "record key '#{key}' deleted")
  end

  match(_, do: send_resp(conn, 404, "Oops!"))
end