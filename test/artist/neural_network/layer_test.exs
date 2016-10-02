defmodule Artist.NeuralNetwork.LayerTest do
  use ExUnit.Case

  alias Artist.NeuralNetwork.Layer

  doctest Layer

  test "create" do
    layer = Layer.create(10)
    assert length(layer.neurons) == 10
  end

  test "connect_to" do
    src_layer = Layer.create(10)
    dest_layer = Layer.create(2)
    Layer.connect_to(src_layer, dest_layer)

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
end
