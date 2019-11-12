defmodule ElixirTools.TestHelper.MetrixFake do
  use ElixirTools.ContractImpl, module: ElixirTools.Metrix

  @impl true
  def gauge(metric, amount, tags) do
    send(self(), [:gauge, metric, amount, tags])
    :ok
  end

  @impl true
  def increment(metric, amount, tags) do
    send(self(), [:increment, metric, amount, tags])
    :ok
  end
end
