defmodule CommandLine.ClassifierHelper do
  def process(inputs, json) do
    json |> NeuralNetwork.Serializer.deserialize |> NeuralNetwork.process(inputs)
  end

  def write_output(result) do
    %{ result: result } |> Poison.encode! |> IO.puts
  end
end
