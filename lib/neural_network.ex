defmodule NeuralNetwork do

  defstruct layers: []
  
  alias NeuralNetwork.Layer

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

  def prop_forward(network) do
    Enum.at(network.layers, 0)
    |> Layer.prop_forward

    Enum.drop(network.layers, 1)
    |> Enum.each(fn layer ->
      Layer.update_outputs(layer)
      Layer.prop_forward(layer)
    end)
    network
  end

  def prop_backward(network, target_outputs) do
    Enum.reverse(network.layers)
    |> Enum.each(fn layer ->
      Layer.prop_backward(layer, target_outputs)
    end)
    network
  end

  def adjust_weights(network, target_outputs) do
    Enum.reverse(network.layers)
    |> Enum.each(fn layer ->
      Layer.adjust_weights(layer, target_outputs)
    end)
    network
  end

  def process(network, inputs) do
    NeuralNetwork.set_inputs(network, inputs)
    |> NeuralNetwork.prop_forward
    |> NeuralNetwork.get_outputs
  end

  def train(network, inputs, target_outputs) do
    NeuralNetwork.set_inputs(network, inputs)
    |> NeuralNetwork.prop_forward
    |> NeuralNetwork.prop_backward(target_outputs)
    |> NeuralNetwork.adjust_weights(target_outputs)
  end
end
