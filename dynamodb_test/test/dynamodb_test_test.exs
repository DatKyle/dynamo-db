defmodule DynamodbTestTest do
  use ExUnit.Case
  doctest DynamodbTest

  test "greets the world" do
    assert DynamodbTest.hello() == :world
  end
end
