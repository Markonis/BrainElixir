defmodule CommandLine.CompositeClassifier do

  alias CommandLine.ImageClassifier
  alias CommandLine.GenericClassifier
  alias CommandLine.ClassifierHelper

  def run(json, options) do
    configuration = Poison.decode!(json)
    preprocess(configuration, options) |> classify(configuration)
  end

  def preprocess(configuration, options) do
    type = Map.get(configuration, "type")
    json = Map.get(configuration, "preprocessor") |> File.read!

    case type do
      "image"   -> ImageClassifier.run(json, options)
      "generic" -> GenericClassifier.run(json, options)
    end
  end

  def classify(inputs, configuration) do
    json = configuration
    |> Map.get("classifier")
    |> File.read!
    ClassifierHelper.process(inputs, json)
  end
end
