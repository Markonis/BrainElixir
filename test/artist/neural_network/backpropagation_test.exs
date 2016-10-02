defmodule Artist.NeuralNetwork.BackpropagationTest do
  use ExUnit.Case

  alias Artist.NeuralNetwork.Backpropagation
  alias Artist.NeuralNetwork.Neuron

  test "total_output_err_deriv for output neuron" do
    forward_err_derivs = %{123 => 0.6, 12 => 0.8}
    state = %Neuron{output: 1.2}

    result = Backpropagation.total_output_err_deriv(state, 2)
    assert result == 0.8
  end

  test "total_output_err_deriv for hidden neuron" do
    forward_err_derivs = %{123 => 0.6, 12 => 0.8}
    state = %Neuron{
      out_conn: [1, 2],
      forward_err_derivs: forward_err_derivs}

    result = Backpropagation.total_output_err_deriv(state, nil)
    assert result == 1.4
  end
end
