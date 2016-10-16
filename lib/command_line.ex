defmodule CommandLine do
  def main(args) do
    args |> parse_arguments |> process |> write_output
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
    IO.puts " - <cmd>         = train-classifier | classify | train-image-classifier | classify-image"
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

  def write_output(result) do
    %{ result: result } |> Poison.encode! |> IO.puts
  end
end
