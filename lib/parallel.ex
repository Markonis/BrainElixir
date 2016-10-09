defmodule Parallel do
  def map(enumerable, fun) do
    parent      = self
    chunk_size  = chunk_size(enumerable)

    enumerable
    |> Enum.chunk(chunk_size, chunk_size, [])
    |> Enum.map(fn chunk ->
      spawn fn -> map_chunk(parent, chunk, fun) end
    end)
    |> Enum.flat_map(fn pid ->
      receive do {^pid, chunk_result} -> chunk_result end
    end)
  end

  def each(enumerable, fun) do
    parent      = self
    chunk_size  = chunk_size(enumerable)

    enumerable
    |> Enum.chunk(chunk_size, chunk_size, [])
    |> Enum.map(fn chunk ->
      spawn fn -> map_chunk(parent, chunk, fun) end
    end)
    |> Enum.map(fn pid ->
      receive do {^pid, _result} -> :ok end
    end)
    :ok
  end

  def chunk_size(enumerable) do
    num_cores = :erlang.system_info(:logical_processors)
    Enum.max [div(length(enumerable), num_cores), 1]
  end

  defp map_chunk(parent, chunk, fun) do
    result = Enum.map chunk, fn item -> fun.(item) end
    send(parent, {self, result})
  end
end
