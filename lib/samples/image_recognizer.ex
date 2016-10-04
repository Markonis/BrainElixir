defmodule Samples.ImageRecognizer do
  def create_network(dim) do
    NeuralNetwork.create([dim, 16, 2])
  end

  def train do
    circle    = ImageProcessor.load("samples/circle.png")
    triangle  = ImageProcessor.load("samples/triangle.png")

    inputs = [circle.pixels, triangle.pixels]
    |> Enum.map(&List.flatten/1)
    |> Enum.map(&ImageProcessor.to_grayscale/1)
    |> Enum.map(&ImageProcessor.normalize_values/1)

    outputs = [ [1, 0], [0, 1] ]
    input_output_pairs = List.zip [inputs, outputs]

    dim = length(Enum.at(inputs, 0))
    network = create_network(dim)

    Enum.each 1..3000, fn step ->
      Enum.each input_output_pairs, fn {inputs, target_outputs} ->
        NeuralNetwork.train(network, inputs, target_outputs)
      end
      IO.puts "Step: #{step}"
    end

    %{
      dim:              dim,
      circle_inputs:    Enum.at(inputs, 0),
      triangle_inputs:  Enum.at(inputs, 1),
      network:          network
    }
  end
end
