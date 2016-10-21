defmodule NeuralNetwork.Autoencoder do
  def remove_output_layer(network) do
    num_layers = length(network.layers)
    hidden_layers = Enum.take(network.layers, num_layers - 1)
    %{network | layers: hidden_layers}
  end

  def trim_json_file(file) do
    new_json = File.read!(file)
    |> NeuralNetwork.Serializer.deserialize
    |> remove_output_layer
    |> NeuralNetwork.Serializer.serialize
    File.write(file, new_json)
  end
end
