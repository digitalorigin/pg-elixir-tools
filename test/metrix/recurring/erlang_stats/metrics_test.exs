defmodule ElixirTools.Metrix.Recurring.ErlangStats.MetricsTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Recurring.ErlangStats.Metrics

  describe "all/0" do
    test "returns the metrics to measure" do
      assert Metrics.all() == %{
               gauge: [
                 Metrics.AtomMemory,
                 Metrics.EtsMemory,
                 Metrics.ProcessMemory,
                 Metrics.TotalMemory
               ]
             }
    end
  end
end
