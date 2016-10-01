defmodule Artist.NeuralNetworkTest do
  use ExUnit.Case

  alias Artist.NeuralNetwork

  doctest NeuralNetwork

  test "create" do
    network = NeuralNetwork.create([5, 2, 3])
    layer_sizes = Enum.map network.layers, fn (layer) ->
      length(layer.neurons)
    end

    assert layer_sizes == [5, 2, 3]
  end
end
