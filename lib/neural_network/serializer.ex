defmodule NeuralNetwork.Serializer do

  def serialize(network) do
    Poison.encode! %{
      configuration: NeuralNetwork.get_configuration(network),
      in_conns: NeuralNetwork.get_in_conns(network)
    }
  end

  def deserialize(json) do
    data = Poison.decode! json

    network = data
    |> Map.get("configuration")
    |> NeuralNetwork.create

    in_conns = data
    |> Map.get("in_conns")
    |> to_in_conn_structs

    NeuralNetwork.set_in_conns(network, in_conns)
  end

  def to_in_conn_structs(network_in_conns) do
    Enum.map network_in_conns, fn layer_in_conns ->
      Enum.map layer_in_conns, fn neuron_in_conns ->
        Enum.map neuron_in_conns, fn in_conn ->
          NeuralNetwork.Connection.from_map(in_conn)
        end
      end
    end
  end
end
