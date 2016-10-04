defmodule NeuralNetwork.Layer do
  defstruct neurons: []

  alias NeuralNetwork.Layer
  alias NeuralNetwork.Neuron

  def create(num) do
    neurons = 1..num |> Enum.map(fn _ -> Neuron.create end)
    %Layer{neurons: neurons}
  end

  def connect(src, dest) do
    for src_pid <- src.neurons, dest_pid <- dest.neurons do
      GenServer.call(src_pid, {:connect_to, dest_pid})
    end
    reset_weights(dest)
  end

  def reset_weights(layer) do
    Parallel.each layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :reset_weights)
    end
  end

  def set_outputs(layer, outputs) do
    List.zip([layer.neurons, outputs])
    |> Parallel.each(fn {neuron_pid, output} ->
      GenServer.call(neuron_pid, {:set_output, output})
    end)
  end

  def get_outputs(layer) do
    Enum.map layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :get_state).output
    end
  end

  def prop_forward(layer) do
    Parallel.each layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :prop_forward)
    end
  end

  def update_outputs(layer) do
    Parallel.each layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :update_output)
    end
  end

  def prop_backward(layer, target_outputs) do
    List.zip([layer.neurons, target_outputs])
    |> Parallel.each(fn {neuron_pid, target_output} ->
      GenServer.call(neuron_pid, {:prop_backward, target_output})
    end)
  end

  def adjust_weights(layer, target_outputs) do
    List.zip([layer.neurons, target_outputs])
    |> Parallel.each(fn {neuron_pid, target_output} ->
      GenServer.call(neuron_pid, {:adjust_weights, target_output})
    end)
  end

  def get_in_conns(layer) do
    Enum.map layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :get_in_conn)
    end
  end

  def set_in_conns(layer, in_conns) do
    List.zip([layer.neurons, in_conns])
    |> Parallel.each(fn {neuron_pid, conn_list} ->
      GenServer.call(neuron_pid, {:set_in_conn, conn_list})
    end)
  end
end
