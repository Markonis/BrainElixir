defmodule Samples.Xor do
  def create_network do
    NeuralNetwork.create([2, 4, 2, 1])
  end

  def train do
    network = create_network

    input_output_pairs = [
      {[0, 0], [0]}, {[0, 1], [1]},
      {[1, 0], [1]}, {[1, 1], [0]}]

    Enum.each 1..15_000, fn _ ->
      Enum.each input_output_pairs, fn {inputs, target_outputs} ->
        NeuralNetwork.train(network, inputs, target_outputs)
      end
    end

    network
  end
end
