defmodule CommandLine.TrainerHelper do
  require Logger

  def create_network(configuration, options) do
    if options[:input] != nil do
      File.read!(options[:input]) |> NeuralNetwork.Serializer.deserialize
    else
      configuration
      |> Map.get("layers")
      |> NeuralNetwork.create
    end
  end

  def create_input_output_pairs(inputs) do
    inputs
    |> Enum.with_index
    |> Enum.map(fn {input, index} ->
      output = List.duplicate(0, length(inputs)) |> List.replace_at(index, 1)
      {input, output}
    end)
  end

  def write_output(network, options) do
    json = NeuralNetwork.Serializer.serialize network
    File.write(options[:output], json)
  end

  def train(input_output_pairs, network, configuration, options) do
    iterations = Map.get configuration, "iterations"

    Enum.each 1..iterations, fn step ->
      Enum.each input_output_pairs, fn {inputs, target_outputs} ->
        NeuralNetwork.train(network, inputs, target_outputs)
      end
      Logger.info("Iteration: #{step}")
      write_output(network, options)
    end

    network
  end
end
