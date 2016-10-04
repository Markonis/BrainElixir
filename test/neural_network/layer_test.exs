defmodule NeuralNetwork.LayerTest do
  use ExUnit.Case

  alias NeuralNetwork.Layer

  doctest Layer

  test "create" do
    layer = Layer.create(10)
    assert length(layer.neurons) == 10
  end

  test "connect" do
    src_layer = Layer.create(10)
    dest_layer = Layer.create(2)
    Layer.connect(src_layer, dest_layer)

    first_pid = src_layer.neurons |> Enum.at(0)
    first_state = GenServer.call(first_pid, :get_state)

    assert length(first_state.out_conn) == 2
  end

  test "set_outputs" do
    layer = Layer.create(3)
    Layer.set_outputs(layer, [1, 2, 3])

    outputs = Layer.get_outputs(layer)

    assert outputs == [1, 2, 3]
  end

  test "get_outputs" do
    layer = Layer.create(3)
    Layer.set_outputs(layer, [4, 5, 6])

    outputs = Layer.get_outputs(layer)

    assert outputs == [4, 5, 6]
  end

  test "get_in_conns" do
    first_layer = Layer.create(2)
    second_layer = Layer.create(2)
    Layer.connect(first_layer, second_layer)

    in_conns = Layer.get_in_conns(second_layer)

    expected = [
      [
        %NeuralNetwork.Connection{index: 0, value: 0, weight: 0.5},
        %NeuralNetwork.Connection{index: 1, value: 0, weight: 0.5}
      ],
      [
        %NeuralNetwork.Connection{index: 0, value: 0, weight: 0.5},
        %NeuralNetwork.Connection{index: 1, value: 0, weight: 0.5}
      ]
    ]

    assert in_conns == expected
  end

  test "set_in_conns" do
    first_layer = Layer.create(2)
    second_layer = Layer.create(2)
    Layer.connect(first_layer, second_layer)

    initial_in_conns = Layer.get_in_conns(second_layer)

    expected = [
      [
        %NeuralNetwork.Connection{index: 0, value: 1, weight: 0.1},
        %NeuralNetwork.Connection{index: 1, value: 1, weight: 0.9}
      ],
      [
        %NeuralNetwork.Connection{index: 0, value: 2, weight: 0.2},
        %NeuralNetwork.Connection{index: 1, value: 2, weight: 0.8}
      ]
    ]

    Layer.set_in_conns(second_layer, expected)
    in_conns = Layer.get_in_conns(second_layer)

    assert initial_in_conns != expected
    assert in_conns == expected
  end
end
