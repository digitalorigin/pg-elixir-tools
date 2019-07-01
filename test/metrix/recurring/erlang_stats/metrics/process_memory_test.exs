defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.ProcessMemoryTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Recurring.ErlangStats.Metrics.ProcessMemory

  defmodule FakeMeasureModule do
    def memory(value) do
      send(self(), [value])
      20
    end
  end

  describe "measure/1" do
    test "returns the correct value" do
      assert {:ok, "node.memory.process", 20, %{}} ==
               ProcessMemory.measure(measure_module: FakeMeasureModule)

      assert_received([:processes])
    end
  end
end
