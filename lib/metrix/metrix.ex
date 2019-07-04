defmodule ElixirTools.Metrix do
  @moduledoc false

  use GenServer

  alias __MODULE__
  alias ElixirTools.Metrix.Adapters.Adapter

  require Logger

  @adapter Application.get_env(:pagantis_elixir_tools, ElixirTools.Metrix)[:adapter]

  @typep opts :: {:adapter_module, module}

  # Client

  @spec start_link(any) :: {:ok, pid} | {:error, term}
  def start_link(opts) do
    GenServer.start_link(Metrix, opts, name: Metrix)
  end

  @spec count(Adapter.metric(), Adapter.value(), Adapter.tag_map(), [opts]) :: :ok | :error
  def count(metric, value, tags \\ %{}, opts \\ []) do
    args = [metric, value, to_tags(tags, opts)]
    to_adapter(:count, args, opts)
  end

  @spec increment(Adapter.metric(), Adapter.value(), Adapter.tag_map(), [opts]) :: :ok | :error
  def increment(metric, value, tags \\ %{}, opts \\ []) do
    args = [metric, value, to_tags(tags, opts)]
    to_adapter(:increment, args, opts)
  end

  @spec decrement(Adapter.metric(), Adapter.value(), Adapter.tag_map(), [opts]) :: :ok | :error
  def decrement(metric, value, tags \\ %{}, opts \\ []) do
    args = [metric, value, to_tags(tags, opts)]
    to_adapter(:decrement, args, opts)
  end

  @spec gauge(Adapter.metric(), Adapter.value(), Adapter.tag_map(), [opts]) :: :ok | :error
  def gauge(metric, value, tags \\ %{}, opts \\ []) do
    args = [metric, value, to_tags(tags, opts)]
    to_adapter(:gauge, args, opts)
  end

  @spec histogram(Adapter.metric(), Adapter.value(), Adapter.tag_map(), [opts]) :: :ok | :error
  def histogram(metric, value, tags \\ %{}, opts \\ []) do
    args = [metric, value, to_tags(tags, opts)]
    to_adapter(:histogram, args, opts)
  end

  @spec timing(Adapter.metric(), Adapter.value(), Adapter.tag_map(), [opts]) :: :ok | :error
  def timing(metric, value, tags \\ %{}, opts \\ []) do
    args = [metric, value, to_tags(tags, opts)]
    to_adapter(:timing, args, opts)
  end

  @spec to_adapter(atom, [any], [opts]) :: :ok | :error
  defp to_adapter(method, args, opts) do
    GenServer.cast(Metrix, {:send_metric, method, args, opts})
  end

  @spec to_tags(Adapter.tag_map(), [opts]) :: any
  def to_tags(tags, opts) do
    adapter_module = opts[:adapter_module] || @adapter
    default_tags = Application.get_env(:pagantis_elixir_tools, Metrix)[:default_tags]

    adapter_module.to_tags(Map.merge(tags, default_tags))
  end

  # Server

  @typep connect_opt :: {:adapter, module} | {:sleep_ms, pos_integer}
  @typep metric_opt :: {:adapter, module}
  @typep state :: nil

  @impl true
  @spec init([connect_opt]) :: {:ok, state}
  def init(opts) do
    connect_adapter(opts)

    {:ok, nil}
  end

  @impl true
  @spec handle_cast({:send_metric, atom, any, [metric_opt]}, state) :: {:noreply, state}
  def handle_cast({:send_metric, method, args, opts}, state) do
    adapter_module = opts[:adapter_module] || @adapter

    try do
      apply(adapter_module, method, args)
    rescue
      e -> Logger.error(fn -> "Metric #{inspect(args)} not sent: #{inspect(e)}" end)
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:connect_adapter, opts}, state) do
    connect_adapter(opts)

    {:noreply, state}
  end

  @spec connect_adapter([connect_opt]) :: :ok
  defp connect_adapter(opts) do
    adapter = opts[:adapter_module] || @adapter
    sleep_time = opts[:sleep_ms] || 5000

    try do
      adapter.connect()
      :ok
    rescue
      e ->
        Logger.error(fn ->
          "Could not connect to adapter: #{inspect(e)}. Retry in #{sleep_time} ms"
        end)

        Process.send_after(self(), {:connect_adapter, opts}, sleep_time)
    end
  end
end
