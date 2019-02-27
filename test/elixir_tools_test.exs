defmodule ElixirToolsTest do
  use ExUnit.Case
  doctest ElixirTools

  test "greets the world" do
    assert ElixirTools.hello() == :world
  end
end
