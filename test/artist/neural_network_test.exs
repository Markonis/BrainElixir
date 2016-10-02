defmodule Artist.NeuralNetworkTest do
  use ExUnit.Case

  alias Artist.NeuralNetwork
  alias Artist.NeuralNetwork.Layer

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

  test "update_outputs" do
    output = NeuralNetwork.create([3, 2, 1])
    |> NeuralNetwork.set_inputs([1, 1, 1])
    |> NeuralNetwork.update_outputs
    |> NeuralNetwork.get_outputs
    |> Enum.at(0)

    assert_in_delta output, 0.6750375273768237, 0.001
  end
end
