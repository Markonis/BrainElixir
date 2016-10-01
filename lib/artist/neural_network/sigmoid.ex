defmodule Artist.NeuralNetwork.Sigmoid do
  def value(x) do
    e = 2.718281828459045
    1 / (1 + :math.pow(e, -x))
  end

  def derivative(x) do
    value(x) * (1 - value(x))
  end
end
