defmodule CommandLine do
  def main(args) do
    args |> parse_arguments |> process
  end

  def parse_arguments(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [
        command: :string,
        input: :string,
        output: :string
      ]
    )
    options
  end

  def process([]) do
    IO.puts "\n================"
    IO.puts "\nUsage: brain_elixir --command <cmd> --config <config file> --input <input file> --output <output file>"
    IO.puts "\nWhere:"
    IO.puts " - <cmd>         = classify-image | train-image-classifier"
    IO.puts " - <config file> = path to your configuration JSON file"
    IO.puts " - <input file>  = path to your input file"
    IO.puts " - <output file> = path to your output file"
    IO.puts "\n================\n"
  end

  def process(options) do
    json = options[:config] |> File.read!
    case options[:cmd] do
      "train-classifier" ->
        CommandLine.GenericClassifierTrainer.run(json, options)
      "classify" ->
        CommandLine.GenericClassifier.run(json, options)
      "train-image-classifier" ->
        CommandLine.ImageClassifierTrainer.run(json, options)
      "classify-image" ->
        CommandLine.ImageClassifier.run(json, options)
      _ -> process []
    end
  end
end
