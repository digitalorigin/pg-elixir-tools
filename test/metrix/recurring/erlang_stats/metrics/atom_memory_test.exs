defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.AtomMemoryTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Recurring.ErlangStats.Metrics.AtomMemory

  defmodule FakeMeasureModule do
    def memory(value) do
      send(self(), [value])
      5
    end
  end

  describe "measure/1" do
    test "returns the correct value" do
      assert {:ok, "node.memory.atom", 5, %{}} ==
               AtomMemory.measure(measure_module: FakeMeasureModule)

      assert_received([:atom])
    end
  end
end
