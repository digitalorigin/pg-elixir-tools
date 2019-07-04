defmodule ElixirTools.Metrix.Recurring.ErlangStats.Metrics do
  alias __MODULE__

  @type metric :: binary
  @type value :: non_neg_integer
  @type tags :: map
  @type on_measure :: {:ok, metric, value, tags} | {:error, term}

  @callback measure() :: on_measure

  @gauges [
    Metrics.AtomMemory,
    Metrics.EtsMemory,
    Metrics.ProcessMemory,
    Metrics.TotalMemory
  ]

  @doc """
  Returns all metrics modules to measure
  """
  @spec all() :: map
  def all() do
    %{
      gauge: @gauges
    }
  end
end
