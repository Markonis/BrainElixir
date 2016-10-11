defmodule CommandLine.ImageClassifierTrainer do
  require Logger

  def run(json, options) do
    configuration = Poison.decode! json
    network = create_network(configuration, options)

    configuration
    |> load_images
    |> prepare_inputs(configuration)
    |> create_input_output_pairs
    |> train(network, configuration, options)
    |> write_output(options)
  end

  def create_network(configuration, options) do
    if options[:input] != nil do
      File.read!(options[:input]) |> NeuralNetwork.deserialize
    else
      configuration
      |> Map.get("layers")
      |> NeuralNetwork.create
    end
  end

  def load_images(configuration) do
    configuration
    |> Map.get("paths")
    |> Enum.map(&ImageProcessor.load/1)
  end

  def prepare_inputs(images, configuration) do
    images
    |> Enum.map(fn image -> image.pixels end)
    |> Enum.map(&List.flatten/1)
    |> Enum.map(fn pixels -> process_pixels(pixels, configuration) end)
    |> Enum.map(&ImageProcessor.normalize_values/1)
  end

  def process_pixels(pixels, configuration) do
    if Map.get(configuration, "mode") == "grayscale" do
      ImageProcessor.to_grayscale pixels
    else
      ImageProcessor.flatten_pixels pixels
    end
  end

  def create_input_output_pairs(inputs) do
    inputs
    |> Enum.with_index
    |> Enum.map(fn {pixels, index} ->
      output = List.duplicate(0, length(inputs)) |> List.replace_at(index, 1)
      {pixels, output}
    end)
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

  def write_output(network, options) do
    json = NeuralNetwork.serialize network
    File.write(options[:output], json)
  end
end
