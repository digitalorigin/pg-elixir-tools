defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics.AtomMemory do
  @moduledoc false

  @behaviour ElixirTools.Metrix.Recurring.ErlangStats.Metrics

  @metric "node.memory.atom"

  @impl true
  def measure(opts \\ []) do
    measure_module = opts[:measure_module] || :erlang
    value = measure_module.memory(:atom)

    {:ok, @metric, value, %{}}
  end
end
