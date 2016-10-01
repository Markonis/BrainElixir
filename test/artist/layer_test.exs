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

  test "set_outputs" do
    layer = Layer.create(3)
    Layer.set_outputs(layer, [1, 2, 3])

    :timer.sleep(10)

    outputs = Enum.map layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :get_state).output
    end

    assert outputs == [1, 2, 3]
  end
end
