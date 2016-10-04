defmodule UtilTest do
  use ExUnit.Case

  test "chunk_2d" do
    enumerable = [
      [11, 12, 13, 14],
      [21, 22, 23, 24],
      [31, 32, 33, 34],
      [41, 42, 43, 44]
    ]

    expected = [
      [ [11, 12],
        [21, 22] ],
      [ [31, 32],
        [41, 42] ],
      [ [13, 14],
        [23, 24] ],
      [ [33, 34],
        [43, 44] ]
    ]

    result = Util.chunk_2d(enumerable, width: 2, height: 2)
    assert result == expected
  end

  test "replace_in_map" do
    map = %{
      a: %{x: 1, y: 10},
      b: %{x: 2, y: 10},
      c: %{x: 3, y: 10}
    }

    element = %{x: 2, y: 20}

    expected = %{
      a: %{x: 1, y: 10},
      b: %{x: 2, y: 20},
      c: %{x: 3, y: 10}
    }

    result = Util.replace_in_map map, element, fn (a, b) ->
      a.x == b.x
    end

    assert result == expected
  end
end
