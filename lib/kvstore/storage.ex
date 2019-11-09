defmodule KVstore.Storage do
    
    def create(obj, ttl) do
        :dets.open_file(:disc_storage, [type: :set])
        :dets.insert_new(:disc_storage, obj)
        :timer.apply_after(String.to_integer(ttl)*1000, :dets, :delete, :disc_storage)
    end

    def read(obj) do
        try do
            :dets.lookup(:disc_storage, obj)
        rescue
            ArgumentError -> "record expired"
        end    
    end
    
    def update(obj) do
        :dets.insert(:disc_storage, obj)
    end

    def delete(obj) do
        :dets.delete(:disc_storage, obj)
    end
end