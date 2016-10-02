defmodule Artist.NeuralNetwork do
  defstruct layers: []
  alias Artist.NeuralNetwork
  alias Artist.NeuralNetwork.Layer

  def create(configuration) do
    layers = create_layers(configuration)
    connect_layers(layers)
    %NeuralNetwork{layers: layers}
  end

  def create_layers(configuration) do
    Enum.map configuration, fn num ->
      Layer.create(num)
    end
  end

  def connect_layers(layers) do
    layers
    |> Enum.chunk(2, 1)
    |> Enum.each(fn [src, dest] -> Layer.connect(src, dest) end)
  end

  def set_inputs(network, inputs) do
    Enum.at(network.layers, 0)
    |> Layer.set_outputs(inputs)
    network
  end

  def get_outputs(network) do
    Enum.at(network.layers, -1) |> Layer.get_outputs
  end
end
