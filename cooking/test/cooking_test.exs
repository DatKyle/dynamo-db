defmodule CookingTest do
  use ExUnit.Case
  doctest Cooking

  test "greets the world" do
    assert Cooking.hello() == :world
  end
end
