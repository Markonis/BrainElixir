defmodule CommandLine.ImageHelper do
  def prepare_inputs(image_config) do
    path = Map.get(image_config, "path")
    type = Map.get(image_config, "type")

    ImageProcessor.load(path).pixels
    |> List.flatten
    |> process_pixels(type)
    |> ImageProcessor.normalize_values
  end

  def process_pixels(pixels, type) do
    if type == "grayscale" do
      ImageProcessor.to_grayscale pixels
    else
      ImageProcessor.flatten_pixels pixels
    end
  end
end
