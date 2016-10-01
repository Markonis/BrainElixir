defmodule Artist.NeuralNetwork.NeuronTest do
  use ExUnit.Case

  alias Artist.NeuralNetwork.Neuron
  alias Artist.NeuralNetwork.Connection

  doctest Neuron

  test "connect_to" do
    state = %Neuron{}

    new_state = Neuron.connect_to(state, 123)

    expected_state = %Neuron{out_conn: [123]}
    assert new_state == expected_state
  end

  test "update_input" do
    state = %Neuron{in_conn: %{123 => %Connection{}}}

    new_state = Neuron.update_input(state, 123, 1)

    expected_state = %Neuron{
      in_conn: %{123 => %Connection{value: 1}}}

    assert new_state == expected_state
  end

  test "prop_forward" do
    source_pid = Neuron.create
    dest_pid = Neuron.create

    GenServer.cast(source_pid, {:connect_to, dest_pid})
    GenServer.cast(source_pid, {:set_output, 1})
    GenServer.cast(source_pid, :prop_forward)

    :timer.sleep(10) # Allow for the casts to be processed

    dest_state = GenServer.call(dest_pid, :get_state)

    expected_state = %Neuron{in_conn: %{source_pid => %Connection{value: 1}}}

    assert dest_state == expected_state
  end
end
