defmodule NeuralNetwork.Connection do
  defstruct weight: 0, value: 0, index: 0

  alias NeuralNetwork.Connection

  def from_map(map) do
    %Connection{
      weight: Map.get(map, "weight"),
      index: Map.get(map, "index")
    }
  end
end
