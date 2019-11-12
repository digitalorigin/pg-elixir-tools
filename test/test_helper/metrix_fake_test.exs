defmodule ElixirTools.TestHelper.MetrixFakeTest do
  use ExUnit.Case, async: true

  alias ElixirTools.TestHelper.MetrixFake

  describe "gauge/3" do
    test "returns expected value and sends expected message" do
      assert MetrixFake.gauge("metric", "amount", "tags") == :ok
      assert_received [:gauge, "metric", "amount", "tags"]
    end
  end

  describe "increment/3" do
    test "returns expected value and sends expected message" do
      assert MetrixFake.increment("metric", "amount", "tags") == :ok
      assert_received [:increment, "metric", "amount", "tags"]
    end
  end
end
