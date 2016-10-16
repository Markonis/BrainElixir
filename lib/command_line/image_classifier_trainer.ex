defmodule CommandLine.ImageClassifierTrainer do

  alias CommandLine.TrainerHelper

  def run(json, options) do
    configuration = Poison.decode! json
    network = TrainerHelper.create_network(configuration, options)

    configuration
    |> load_images
    |> prepare_inputs(configuration)
    |> TrainerHelper.create_input_output_pairs
    |> TrainerHelper.train(network, configuration, options)

    :ok
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
end
