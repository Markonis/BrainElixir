defmodule NeuralNetwork.Neuron do
  defstruct in_conn: %{}, out_conn: [],
            output: 0, forward_err_derivs: %{}

  use GenServer

  alias NeuralNetwork.Neuron
  alias NeuralNetwork.Connection
  alias NeuralNetwork.Sigmoid
  alias NeuralNetwork.Backpropagation

  def create do
    {:ok, pid} = GenServer.start_link(__MODULE__, %Neuron{})
    pid
  end

  def connect_to(state, neuron_pid) do
    GenServer.call(neuron_pid, {:update_input, self, 0})
    add_out_conn(state, neuron_pid)
  end

  def add_out_conn(state, neuron_pid) do
    %{state | out_conn: [neuron_pid | state.out_conn]}
  end

  def prop_forward(state) do
    Enum.each state.out_conn, fn dest_pid ->
      GenServer.call(dest_pid, {:update_input, self, state.output})
    end
    state
  end

  def update_input(state, neuron_pid, value) do
    update_input_conn(state, neuron_pid, value)
  end

  def update_input_conn(state, neuron_pid, value) do
    existing_conn = Map.get(state.in_conn, neuron_pid)
    new_conn = case existing_conn do
      nil -> %Connection{value: value, index: new_in_conn_index(state)}
      %Connection{} -> %{existing_conn | value: value}
    end
    %{state | in_conn: Map.put(state.in_conn, neuron_pid, new_conn)}
  end

  def new_in_conn_index(state) do
    Map.keys(state.in_conn) |> length
  end

  def update_output(state) do
    output = input_sum(state)
    |> apply_activation

    %{state | output: output}
  end

  def input_sum(state) do
    state.in_conn
      |> Enum.map(fn {_pid, conn} -> conn.value * conn.weight end)
      |> Enum.sum
  end

  def apply_activation(value) do
    Sigmoid.value(value)
  end

  def update_forward_err_deriv(state, neuron_pid, err_deriv) do
    forward_err_derivs = Map.put(
      state.forward_err_derivs, neuron_pid, err_deriv)

    %{state | forward_err_derivs: forward_err_derivs}
  end

  def reset_weights(state) do
    weight = 1 / length(Map.values(state.in_conn))
    in_conn = Enum.reduce state.in_conn, %{}, fn {neuron_pid, conn}, acc ->
      Map.put(acc, neuron_pid, %{conn | weight: weight})
    end
    %{state | in_conn: in_conn}
  end

  def prop_backward(state, target_output) do
    err_deriv = Backpropagation.backward_output_err_deriv(state, target_output)

    Enum.each state.in_conn, fn {neuron_pid, _conn} ->
      input_weight = Map.get(state.in_conn, neuron_pid).weight

      weighted_err_derriv = err_deriv * input_weight

      GenServer.call(neuron_pid, {:update_forward_err_deriv, self, weighted_err_derriv})
    end
    state
  end

  def adjust_weights(state, target_output) do
    in_conn = Enum.reduce state.in_conn, %{}, fn {input_neuron_pid, conn}, acc ->
      weight_adjustment = Backpropagation.weight_adjustment(
        state, input_neuron_pid, target_output)

      weight = conn.weight + weight_adjustment

      Map.put(acc, input_neuron_pid, %{conn | weight: weight})
    end

    %{state | in_conn: in_conn}
  end

  def get_in_conn(state) do
    state.in_conn
    |> Map.values
    |> Enum.sort_by(fn conn -> conn.index end)
    |> Enum.map(fn conn -> %{weight: conn.weight, index: conn.index} end)
  end

  def set_in_conn(state, conn_list) do
    new_in_conn = Enum.reduce conn_list, state.in_conn, fn conn, map ->
      Util.replace_in_map map, conn, fn (new_conn, old_conn) ->
        new_conn.index == old_conn.index
      end
    end
    %{state | in_conn: new_in_conn}
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

  def handle_cast({:update_forward_err_deriv, neuron_pid, err_deriv}, state) do
    {:noreply, update_forward_err_deriv(state, neuron_pid, err_deriv)}
  end

  # Call Callbacks
  # ================

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:connect_to, neuron_pid}, _from, state) do
    new_state = connect_to(state, neuron_pid)
    {:reply, new_state, new_state}
  end

  def handle_call(:prop_forward, _from, state) do
    new_state = prop_forward(state)
    {:reply, new_state, new_state}
  end

  def handle_call({:update_input, neuron_pid, value}, _from, state) do
    new_state = update_input(state, neuron_pid, value)
    {:reply, new_state, new_state}
  end

  def handle_call(:update_output, _from, state) do
    new_state = update_output(state)
    {:reply, new_state, new_state}
  end

  def handle_call({:set_output, output}, _from, state) do
    new_state = %{state | output: output}
    {:reply, new_state, new_state}
  end

  def handle_call({:update_forward_err_deriv, neuron_pid, err_deriv}, _from, state) do
    new_state = update_forward_err_deriv(state, neuron_pid, err_deriv)
    {:reply, new_state, new_state}
  end

  def handle_call(:reset_weights, _from, state) do
    new_state = reset_weights(state)
    {:reply, new_state, new_state}
  end

  def handle_call({:prop_backward, target_output}, _from, state) do
    new_state = prop_backward(state, target_output)
    {:reply, new_state, new_state}
  end

  def handle_call({:adjust_weights, target_output}, _from, state) do
    new_state = adjust_weights(state, target_output)
    {:reply, new_state, new_state}
  end

  def handle_call(:get_in_conn, _from, state) do
    {:reply, get_in_conn(state), state}
  end

  def handle_call({:set_in_conn, conn_list}, _from, state) do
    new_state = set_in_conn(state, conn_list)
    {:reply, new_state, new_state}
  end
end
