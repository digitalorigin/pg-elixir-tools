defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.EtsMemory do
  @moduledoc false

  @behaviour ElixirTools.Metrix.Recurring.ErlangStats.Metrics

  @metric "node.memory.ets"

  @impl true
  def measure(opts \\ []) do
    measure_module = opts[:measure_module] || :erlang
    value = measure_module.memory(:ets)

    {:ok, @metric, value, %{}}
  end
end
