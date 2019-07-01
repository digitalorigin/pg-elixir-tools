defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.EtsMemoryTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Recurring.ErlangStats.Metrics.EtsMemory

  defmodule FakeMeasureModule do
    def memory(value) do
      send(self(), [value])
      5
    end
  end

  describe "measure/1" do
    test "returns the correct value" do
      assert {:ok, "node.memory.ets", 5, %{}} ==
               EtsMemory.measure(measure_module: FakeMeasureModule)

      assert_received([:ets])
    end
  end
end
