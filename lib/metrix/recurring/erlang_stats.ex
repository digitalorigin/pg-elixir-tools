defmodule ElixirTools.Metrix.Recurring.ErlangStats do
  @moduledoc """
  Sends periodically Erlang metrics to a ElixirTools.Metrix Adapter
  """
  use GenServer

  alias __MODULE__
  alias ElixirTools.Metrix.Recurring.ErlangStats.Metrics

  @typep send_opt :: {:metrics_module, module} | {:metrics_adapter_module, module}

  @valid_metric_types ~w(count increment decrement gauge histogram timing)a

  # client

  @spec start_link(any) :: {:ok, pid}
  def start_link(_) do
    GenServer.start_link(ErlangStats, %{}, name: ErlangStats)
  end

  @doc """
  Collects the erlang statistics and sends them to the adapter.
  """
  @spec send_metrics([send_opt]) :: :ok
  def send_metrics(opts \\ []) do
    metrics_module = opts[:metrics_module] || ErlangStats.Metrics
    metrics = metrics_module.all()

    for {type, metrics_for_type} <- metrics do
      Enum.each(metrics_for_type, &send_sample(type, &1.measure(), opts))
    end

    :ok
  end

  @spec send_sample(atom, Metrics.on_measure(), [send_opt]) :: :ok
  defp send_sample(metric_type, {:ok, metric, value, tags}, opts)
       when metric_type in @valid_metric_types do
    metrics_adapter_module = opts[:metrics_adapter_module] || ElixirTools.Metrix
    apply(metrics_adapter_module, metric_type, [metric, value, tags])
  end

  defp send_sample(_, _, _), do: :noop

  # server

  @impl true
  def init(_) do
    send(self(), :loop_send)

    {:ok, nil}
  end

  @impl true
  def handle_info(:loop_send, state) do
    Process.send_after(self(), :loop_send, 1000)
    send_metrics()

    {:noreply, state}
  end
end
