defmodule CommandLine.GenericClassifierTrainer do

  alias CommandLine.TrainerHelper

  def run(json, options) do
    configuration = Poison.decode! json
    network = TrainerHelper.create_network(configuration, options)

    configuration
    |> load_input_output_pairs
    |> TrainerHelper.train(network, configuration, options)
    |> TrainerHelper.write_output(options)
  end

  def load_input_output_pairs(configuration) do
    configuration
    |> Map.get("input_output_pairs")
    |> Enum.map(fn [input, output] -> {input, output} end)
  end
end
