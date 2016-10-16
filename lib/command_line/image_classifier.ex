defmodule CommandLine.ImageClassifier do

  alias CommandLine.ClassifierHelper
  alias CommandLine.ImageHelper

  def run(json, options) do
    options[:input]
    |> Poison.decode!
    |> ImageHelper.prepare_inputs
    |> ClassifierHelper.process(json)
  end
end
