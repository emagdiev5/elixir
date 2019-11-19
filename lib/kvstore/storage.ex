defmodule KVstore.Storage do
    use GenServer

    def start_link() do
        GenServer.start_link(__MODULE__, [])
    end
    
    def init(data) do
        {:ok, data}    
    end

    def create(process_id, key, value, ttl) do
        GenServer.cast(process_id, {:create, {key, value, ttl}})
    end

    def read(obj) do
        try do
            :dets.open_file(:disc_storage, [type: :set])
            [{key, value, delete_time}] = :dets.lookup(:disc_storage, obj)
            :dets.close(:disc_storage)

            if delete_time < :os.system_time(:seconds) do
                delete(key)
                raise MatchError
            end
            {key, value} 
        rescue
            MatchError -> "no record found"
        end    
    end
    
    def update(process_id, key, value, ttl) do
        GenServer.cast(process_id, {:create, {key, value, ttl}})
    end

    def delete(key) do
        :dets.open_file(:disc_storage, [type: :set])
        :dets.delete(:disc_storage, key)
        :dets.close(:disc_storage)
    end

    def handle_cast({:create, {key, value, ttl}}, state) do
        :dets.open_file(:disc_storage, [type: :set])
        delete_time = :os.system_time(:seconds) + String.to_integer(ttl)
        :dets.insert_new(:disc_storage, {key, value, delete_time})
        :dets.close(:disc_storage)

        :timer.sleep(String.to_integer(ttl)*1000)

        mes = delete(key)
        IO.puts("delete func message #{inspect mes}")
        {:noreply, state}
    end
end