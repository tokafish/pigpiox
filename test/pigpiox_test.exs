defmodule PigpioxTest do
  use ExUnit.Case
  doctest Pigpiox

  test "greets the world" do
    assert Pigpiox.hello() == :world
  end
end
