defmodule CommandLine.ImageClassifier do

  alias CommandLine.ClassifierHelper

  def run(json, options) do
    options[:input]
    |> prepare_inputs
    |> ClassifierHelper.process(json)
    |> ClassifierHelper.write_output
  end

  def prepare_inputs(path) do
    ImageProcessor.load(path).pixels
    |> List.flatten
    |> ImageProcessor.to_grayscale
    |> ImageProcessor.normalize_values
  end
end
