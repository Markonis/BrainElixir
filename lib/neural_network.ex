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

  def get_configuration(network) do
    Enum.map network.layers, fn layer ->
      length(layer.neurons)
    end
  end

  def get_in_conns(network) do
    Enum.map network.layers, fn layer ->
      Layer.get_in_conns(layer)
    end
  end

  def set_in_conns(network, in_conns) do
    List.zip([network.layers, in_conns])
    |> Enum.each(fn {layer, layer_in_conns} ->
      Layer.set_in_conns(layer, layer_in_conns)
    end)
    network
  end

  def serialize(network) do
    %{
      configuration: get_configuration(network),
      in_conns: get_in_conns(network)
    }
  end

  def deserialize(data) do
    NeuralNetwork.create(data.configuration)
    |> NeuralNetwork.set_in_conns(data.in_conns)
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
