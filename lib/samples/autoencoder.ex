defmodule Samples.Autoencoder do
  require Logger

  def create_network do
    NeuralNetwork.create([100, 24, 100])
  end

  def train do
    alphabet = ImageProcessor.load("samples/alphabet.png")
    letters = ImageProcessor.chunk(alphabet, width: 10, height: 10)

    inputs = letters
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&ImageProcessor.to_grayscale/1)
    |> Enum.map(&ImageProcessor.normalize_values/1)

    input_output_pairs = List.zip [inputs, inputs]

    network = create_network

    Enum.each 1..130, fn step ->
      error = input_output_pairs
      |> Enum.map(fn {inputs, target_outputs} ->
        NeuralNetwork.train(network, inputs, target_outputs)
      end)
      |> Enum.sum

      log(step, error)
    end

    %{
      letters: inputs,
      network: network
    }
  end

  def log(step, error) do
    Logger.info("iteration: #{step}, error: #{error}")
  end
end
