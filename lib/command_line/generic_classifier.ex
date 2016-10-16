defmodule CommandLine.GenericClassifier do
  alias CommandLine.ClassifierHelper

  def run(json, options) do
    options[:input]
    |> prepare_inputs
    |> ClassifierHelper.process(json)
  end

  def prepare_inputs(json) do
    Poison.decode! json
  end
end
