defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.TotalMemoryTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Recurring.ErlangStats.Metrics.TotalMemory

  defmodule FakeMeasureModule do
    def memory(value) do
      send(self(), [value])
      20
    end
  end

  describe "measure/1" do
    test "returns the correct value" do
      assert {:ok, "node.memory.total", 20, %{}} ==
               TotalMemory.measure(measure_module: FakeMeasureModule)

      assert_received([:total])
    end
  end
end
