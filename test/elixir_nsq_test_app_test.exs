defmodule ElixirNsqTestAppTest do
  use ExUnit.Case
  doctest ElixirNsqTestApp

  test "greets the world" do
    assert ElixirNsqTestApp.hello() == :world
  end
end
