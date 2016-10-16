defmodule NeuralNetwork.SerializerTest do
  use ExUnit.Case

  alias NeuralNetwork.Serializer

  test "serialize and deserialize" do
    network1  = NeuralNetwork.create([4,8,2])
    data1     = Serializer.serialize(network1)

    network2  = Serializer.deserialize(data1)
    data2     = Serializer.serialize(network2)

    assert data1 == data2
  end
end
