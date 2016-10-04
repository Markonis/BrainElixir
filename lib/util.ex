defmodule Util do
  def chunk_2d(enumerable, options \\ []) do
    # Provide default options
    defaults = [width: 2, height: 2]
    options = Keyword.merge(defaults, options)
    enumerable
    |> Enum.flat_map(fn row -> chunk_with_index(row, Keyword.get(options, :width)) end)
    |> Enum.group_by(
      fn {elements, index} -> index end,
      fn {elements, index} -> elements end)
    |> Map.values
    |> Enum.flat_map(fn column -> Enum.chunk(column, Keyword.get(options, :height)) end)
  end

  def chunk_with_index(enumerable, count) do
    Enum.chunk(enumerable, count) |> Enum.with_index
  end
end
