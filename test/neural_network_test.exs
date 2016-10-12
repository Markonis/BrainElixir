defmodule NeuralNetworkTest do
  use ExUnit.Case

  alias NeuralNetwork.Layer

  doctest NeuralNetwork

  test "create" do
    network = NeuralNetwork.create([5, 2, 3])
    layer_sizes = Enum.map network.layers, fn (layer) ->
      length(layer.neurons)
    end

    assert layer_sizes == [5, 2, 3]
  end

  test "set_inputs" do
    network = NeuralNetwork.create([3, 1])
    NeuralNetwork.set_inputs(network, [1, 2, 3])

    first_layer = Enum.at(network.layers, 0)
    outputs = Layer.get_outputs(first_layer)

    assert outputs == [1, 2, 3]
  end

  test "prop_forward" do
    output = NeuralNetwork.create([3, 2, 1])
    |> NeuralNetwork.set_inputs([1, 1, 1])
    |> NeuralNetwork.prop_forward
    |> NeuralNetwork.get_outputs
    |> Enum.at(0)

    assert_in_delta output, 0.5, 0.001
  end

  test "prop_backward" do
    network = NeuralNetwork.create([3, 2, 1])
    |> NeuralNetwork.set_inputs([1, 1, 1])
    |> NeuralNetwork.prop_forward
    |> NeuralNetwork.prop_backward([0.8])

    assert network != nil
  end

  test "serialize and deserialize" do
    network1  = NeuralNetwork.create([4,8,2])
    data1     = NeuralNetwork.serialize(network1)

    network2  = NeuralNetwork.deserialize(data1)
    data2     = NeuralNetwork.serialize(network2)

    assert data1 == data2
  end
end
