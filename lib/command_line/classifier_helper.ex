defmodule CommandLine.ClassifierHelper do
  def process(inputs, json) do
    json |> NeuralNetwork.Serializer.deserialize |> NeuralNetwork.process(inputs)
  end
end
