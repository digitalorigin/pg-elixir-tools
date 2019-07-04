defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.TotalMemory do
  @moduledoc false

  @behaviour ElixirTools.Metrix.Recurring.ErlangStats.Metrics

  @metric "node.memory.total"

  @impl true
  def measure(opts \\ []) do
    measure_module = opts[:measure_module] || :erlang
    ets_memory = measure_module.memory(:total)

    {:ok, @metric, ets_memory, %{}}
  end
end
