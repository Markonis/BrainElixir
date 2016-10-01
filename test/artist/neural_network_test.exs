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

  test "set_inputs" do
    network = NeuralNetwork.create([3, 1])
    NeuralNetwork.set_inputs(network, [1, 2, 3])

    first_layer = Enum.at(network.layers, 0)
    outputs = Enum.map first_layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :get_state).output
    end

    assert outputs == [1, 2, 3]
  end
end
