defmodule Artist.NeuralNetwork.Backpropagation do

  alias Artist.NeuralNetwork.Neuron
  alias Artist.NeuralNetwork.Sigmoid

  @doc """
  Calculates the total derivative of the error in respect to the
  output of the neuron.

  There are two possible cases:

  - If the neuron is an output neuron, the error derivative is
  equal to the difference of the target output and the actual output.

  - If the neuron is a hidden layer neuron, than the error derivative
  is equal to the sum of forward_err_derivs.

  """
  def total_output_err_deriv(neuron_state, target_output) do
    if length(neuron_state.out_conn) == 0 do
      # If the neuron does not have output connections, this means
      # that it is an output neuron
      neuron_state.output - target_output
    else
      # If the neuron has output connections, this means that the
      # it is a hidden layer neuron
      Map.values(neuron_state.forward_err_derivs) |> Enum.sum
    end
  end

  def backward_output_err_deriv(neuron_state, target_output) do
    total_output_err_deriv  = total_output_err_deriv(neuron_state, target_output)
    input_output_deriv      = input_output_deriv(neuron_state)

    total_output_err_deriv * input_output_deriv
  end

  def input_output_deriv(neuron_state) do
    Neuron.input_sum(neuron_state) |> Sigmoid.deriv
  end

  def weight_err_deriv(neuron_state, input_neuron_pid, target_output) do
    total_output_err_deriv  = total_output_err_deriv(neuron_state, target_output)
    input_output_deriv      = input_output_deriv(neuron_state)
    input_value             = Map.get(neuron_state.in_conn, input_neuron_pid).value

    total_output_err_deriv * input_output_deriv * input_value
  end

  def weight_adjustment(neuron_state, input_neuron_pid, target_output, learning_factor \\ -0.2) do
    weight_err_deriv(neuron_state, input_neuron_pid, target_output) * learning_factor
  end
end
