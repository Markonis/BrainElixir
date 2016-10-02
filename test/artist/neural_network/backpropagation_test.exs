defmodule Artist.NeuralNetwork.BackpropagationTest do
  use ExUnit.Case

  alias Artist.NeuralNetwork.Backpropagation
  alias Artist.NeuralNetwork.Neuron

  test "total_output_err_deriv for output neuron" do
    state = %Neuron{output: 1.2}

    result = Backpropagation.total_output_err_deriv(state, 2)
    assert result == 0.8
  end

  test "total_output_err_deriv for hidden neuron" do
    state = %Neuron{
      out_conn: [1, 2],
      forward_err_derivs: %{1 => 0.6, 2 => 0.8}}

    result = Backpropagation.total_output_err_deriv(state, nil)
    assert result == 1.4
  end
end
