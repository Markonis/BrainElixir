defmodule Artist.NeuralNetwork.LayerTest do
  use ExUnit.Case

  alias Artist.NeuralNetwork.Neuron
  alias Artist.NeuralNetwork.Layer

  doctest Layer

  test "create" do
    layer = Layer.create(10)
    assert length(layer.neurons) == 10
  end

  test "connect_to" do
    src_layer = Layer.create(10)
    dest_layer = Layer.create(2)
    Layer.connect_to(src_layer, dest_layer)

    :timer.sleep(10)

    first_pid = src_layer.neurons |> Enum.at(0)
    first_state = GenServer.call(first_pid, :get_state)

    assert length(first_state.out_conn) == 2
  end
end
