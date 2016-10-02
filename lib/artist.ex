defmodule Artist do

  alias Artist.NeuralNetwork

  def xor do
    network = NeuralNetwork.create([2, 4, 2, 1])

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
