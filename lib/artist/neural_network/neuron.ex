defmodule Artist.NeuralNetwork.Neuron do
  defstruct in_conn: %{}, out_conn: [], threshold: 0.5, output: 0
  use GenServer

  alias Artist.NeuralNetwork.Neuron
  alias Artist.NeuralNetwork.Connection

  def create do
    {:ok, pid} = GenServer.start_link(__MODULE__, %Neuron{})
    pid
  end

  def connect_to(state, neuron_pid) do
    %{state | out_conn: [neuron_pid | state.out_conn]}
  end

  def prop_forward(state) do
    Enum.each state.out_conn, fn dest_pid ->
      GenServer.cast(dest_pid, {:update_input, self, state.output})
    end
    state
  end

  def update_input(state, neuron_pid, value) do
    existing_conn = Map.get(state.in_conn, neuron_pid)
    new_conn = case existing_conn do
      nil -> %Connection{value: value}
      %Connection{} -> %{existing_conn | value: value}
    end
    %{state | in_conn: Map.put(state.in_conn, neuron_pid, new_conn)}
  end

  # Cast Callbacks
  # ================

  def handle_cast({:connect_to, neuron_pid}, state) do
    {:noreply, connect_to(state, neuron_pid)}
  end

  def handle_cast(:prop_forward, state) do
    {:noreply, prop_forward(state)}
  end

  def handle_cast({:update_input, neuron_pid, conn}, state) do
    {:noreply, update_input(state, neuron_pid, conn)}
  end

  def handle_cast({:set_output, output}, state) do
    {:noreply, %{state | output: output}}
  end

  # Call Callbacks
  # ================

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
