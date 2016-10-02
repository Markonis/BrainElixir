defmodule Artist.NeuralNetwork.Layer do
  defstruct neurons: []
  alias Artist.NeuralNetwork.Layer
  alias Artist.NeuralNetwork.Neuron

  def create(num) do
    neurons = 1..num |> Enum.map(fn _ -> Neuron.create end)
    %Layer{neurons: neurons}
  end

  def connect_to(src, dest) do
    for src_pid <- src.neurons, dest_pid <- dest.neurons do
      GenServer.call(src_pid, {:connect_to, dest_pid})
    end
  end

  def set_outputs(layer, outputs) do
    List.zip([layer.neurons, outputs])
    |> Enum.each(fn {neuron_pid, output} ->
      GenServer.call(neuron_pid, {:set_output, output})
    end)
  end

  def get_outputs(layer) do
    Enum.map layer.neurons, fn neuron_pid ->
      GenServer.call(neuron_pid, :get_state).output
    end
  end

  def prop_forward(layer) do
    Enum.each layer.neurons fn neuron_pid ->
      GenServer.call(neuron_pid, :prop_forward)
    end
  end

  def update_outputs(layer) do
    Enum.each layer.neurons fn neuron_pid ->
      GenServer.call(neuron_pid, :update_output)
    end
  end
end
