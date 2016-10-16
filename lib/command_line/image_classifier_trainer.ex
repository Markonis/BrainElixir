defmodule CommandLine.ImageClassifierTrainer do

  alias CommandLine.TrainerHelper
  alias CommandLine.ImageHelper

  def run(json, options) do
    configuration = Poison.decode! json
    network = TrainerHelper.create_network(configuration, options)

    configuration
    |> prepare_inputs
    |> TrainerHelper.create_input_output_pairs
    |> TrainerHelper.train(network, configuration, options)

    :ok
  end

  def prepare_inputs(configuration) do
    configuration
    |> Map.get("inputs")
    |> Enum.map(&ImageHelper.prepare_inputs/1)
  end
end
