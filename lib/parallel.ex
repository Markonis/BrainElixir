defmodule Parallel do
  def map(enumerable, fun) do
    parent = self
    enumerable
    |> Enum.map(fn item ->
      spawn fn -> send(parent, {self, fun.(item)}) end
    end)
    |> Enum.map(fn pid ->
      receive do {^pid, result} -> result end
    end)
  end

  def each(enumerable, fun) do
    parent = self
    enumerable
    |> Enum.map(fn item ->
      spawn fn ->
        fun.(item)
        send(parent, {self, :ok})
      end
    end)
    |> Enum.map(fn pid ->
      receive do {^pid, :ok} -> :ok end
    end)
    :ok
  end
end
