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
    # Propagete output layer backwards
    List.last(network.layers)
    |> Layer.prop_backward(target_outputs)

    # Propagate hidden layers backwards
    Enum.reverse(network.layers)
    |> Enum.drop(1)
    |> Enum.each(&Layer.prop_backward/1)

    # Return the network for chaining operations
    network
  end

  def adjust_weights(network, target_outputs) do
    # Adjust weights of the output layer
    List.last(network.layers)
    |> Layer.adjust_weights(target_outputs)

    # Adjust weights of the hidden layers
    Enum.reverse(network.layers)
    |> Enum.drop(1)
    |> Enum.each(&Layer.adjust_weights/1)

    # Return the network for chaining operations
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

  def get_neuron_state(network, layer, neuron) do
    network.layers
    |> Enum.at(layer) |> Map.get(:neurons)
    |> Enum.at(neuron) |> GenServer.call(:get_state)
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
    calculate_error(network, target_outputs)
  end

  def calculate_error(network, target_outputs) do
    outputs = NeuralNetwork.get_outputs(network)
    List.zip([outputs, target_outputs])
    |> Enum.map(fn {output, target_output} ->
      :math.pow(target_output - output, 2)
    end)
    |> Enum.sum
  end
end
