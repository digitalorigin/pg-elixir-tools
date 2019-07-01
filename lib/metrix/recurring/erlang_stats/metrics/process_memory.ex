defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.ProcessMemory do
  @moduledoc false

  @behaviour ElixirTools.Metrix.Recurring.ErlangStats.Metrics

  @metric "node.memory.process"

  @impl true
  def measure(opts \\ []) do
    measure_module = opts[:measure_module] || :erlang
    value = measure_module.memory(:processes)

    {:ok, @metric, value, %{}}
  end
end
