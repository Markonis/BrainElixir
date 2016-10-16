defmodule NeuralNetwork.NeuronTest do
  use ExUnit.Case

  alias NeuralNetwork.Neuron
  alias NeuralNetwork.Connection
  alias NeuralNetwork.Sigmoid

  doctest Neuron

  test "add_out_conn" do
    state = %Neuron{}
    new_state = Neuron.add_out_conn(state, 123)
    expected_state = %Neuron{out_conn: [123]}
    assert new_state == expected_state
  end

  test "update_input" do
    state = %Neuron{}

    new_state = state
    |> Neuron.update_input(123, 1)
    |> Neuron.update_input(345, 1)

    new_in_conn = new_state.in_conn

    expected_in_conn = %{
      123 => %Connection{value: 1, index: 0},
      345 => %Connection{value: 1, index: 1}}

    assert new_in_conn == expected_in_conn
  end

  test "input_sum" do
    state = %Neuron{output: 0, in_conn: %{
      1 => %Connection{value: 0.7, weight: 0.3},
      2 => %Connection{value: 0.5, weight: 0.7}}}

    input_sum = Neuron.input_sum(state)

    assert input_sum == 0.7 * 0.3 + 0.5 * 0.7
  end

  test "update_output" do
    state = %Neuron{output: 0, in_conn: %{
      1 => %Connection{value: 0.7, weight: 0.3},
      2 => %Connection{value: 0.5, weight: 0.7}}}

    new_state = Neuron.update_output(state)
    new_output = new_state.output
    expected_output = Sigmoid.value(0.7 * 0.3 + 0.5 * 0.7)

    assert new_output == expected_output
  end

  test "prop_forward" do
    source_pid = Neuron.create
    dest_pid = Neuron.create

    GenServer.call(source_pid, {:connect_to, dest_pid})
    GenServer.call(source_pid, {:set_output, 1})
    GenServer.call(source_pid, :prop_forward)

    dest_state = GenServer.call(dest_pid, :get_state)
    in_conn = dest_state.in_conn
    expected_in_conn = %{source_pid => %Connection{value: 1}}

    assert in_conn == expected_in_conn
  end

  test "update_forward_err_deriv" do
    state = %Neuron{forward_err_derivs: %{123 => 0.6}}
    new_state = state
    |> Neuron.update_forward_err_deriv(123, 0.7)
    |> Neuron.update_forward_err_deriv(456, 1)

    expected = %{123 => 0.7, 456 => 1}
    actual = new_state.forward_err_derivs

    assert actual == expected
  end

  test "prop_backward" do
    source_pid = Neuron.create
    dest_pid = Neuron.create

    GenServer.call(source_pid, {:connect_to, dest_pid})
    GenServer.call(source_pid, {:set_output, 1})
    GenServer.call(source_pid, :prop_forward)
    GenServer.call(dest_pid, :update_output)

    GenServer.call(dest_pid, {:prop_backward, 0.8})

    source_state = GenServer.call(source_pid, :get_state)

    assert length(Map.values(source_state.forward_err_derivs)) == 1
  end

  test "update_weights" do
    state = %Neuron{in_conn: %{
      123 => %Connection{weight: 0.25},
      456 => %Connection{weight: 0.3}}}

    expected_state = %Neuron{in_conn: %{
      123 => %Connection{weight: 0.4},
      456 => %Connection{weight: 0.8}}}

    new_state = Neuron.update_weights(state, %{ 123 => 0.15, 456 => 0.5})
    assert new_state == expected_state
  end

  test "get_in_conn" do
    state = %Neuron{in_conn: %{
      1 => %Connection{value: 0.7, weight: 0.2, index: 1},
      2 => %Connection{value: 0.5, weight: 0.8, index: 0}}}

    in_conn = Neuron.get_in_conn(state)

    expected = [ %{weight: 0.8, index: 0}, %{weight: 0.2, index: 1} ]

    assert in_conn == expected
  end

  test "set_in_conn" do
    state = %Neuron{in_conn: %{
      1 => %Connection{value: 0, weight: 0.5, index: 1},
      2 => %Connection{value: 0, weight: 0.5, index: 0}}}

    conn_list = [
      %Connection{value: 0.7, weight: 0.8, index: 1},
      %Connection{value: 0.6, weight: 0.2, index: 0}
    ]

    expected = [ %{weight: 0.2, index: 0}, %{weight: 0.8, index: 1} ]

    in_conn = state
    |> Neuron.set_in_conn(conn_list)
    |> Neuron.get_in_conn

    assert in_conn == expected
  end
end
