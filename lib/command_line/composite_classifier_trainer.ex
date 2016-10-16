defmodule CommandLine.CompositeClassifierTrainer do

  alias CommandLine.TrainerHelper
  alias CommandLine.ImageHelper

  def run(json, options) do
    configuration = Poison.decode! json
    network = TrainerHelper.create_network(configuration, options)

    configuration
    |> create_preprocessor
    |> preprocess_inputs(configuration)
    |> TrainerHelper.create_input_output_pairs
    |> TrainerHelper.train(network, configuration, options)

    :ok
  end

  def create_preprocessor(configuration) do
    configuration
    |> Map.get("preprocessor")
    |> File.read!
    |> NeuralNetwork.Serializer.deserialize
  end

  def preprocess_inputs(preprocessor, configuration) do
    inputs = Map.get(configuration, "inputs")
    type   = Map.get(configuration, "type")

    inputs
    |> prepare_inputs(type)
    |> run_preprocessor(preprocessor)
  end

  def prepare_inputs(inputs, type) do
    case type do
      "image"   -> Enum.map(inputs, &ImageHelper.prepare_inputs/1)
      "generic" -> inputs
    end
  end

  def run_preprocessor(inputs, preprocessor) do
    Enum.map inputs, fn input ->
      NeuralNetwork.process(preprocessor, input)
    end
  end
end
