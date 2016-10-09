defmodule CommandLine.ImageClassifier do
  def run(json, options) do
    options[:input]
    |> prepare
    |> process(json)
    |> output
  end

  def prepare(path) do
    ImageProcessor.load(path).pixels
    |> List.flatten
    |> ImageProcessor.to_grayscale
    |> ImageProcessor.normalize_values
  end

  def process(inputs, json) do
    json |> NeuralNetwork.deserialize |> NeuralNetwork.process(inputs)
  end

  def output(result) do
    %{ result: result } |> Poison.encode! |> IO.puts
  end
end
