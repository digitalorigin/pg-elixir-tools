defmodule ElixirTools.Metrix.Adapters.Log do
  @behaviour ElixirTools.Metrix.Adapters.Adapter

  require Logger

  @prefix "Statsd log adapter"

  @spec connect() :: any
  def connect, do: Logger.debug(fn -> "#{@prefix}: Connect" end)

  @spec count(any, any, any) :: any
  def count(metric, value, tags) do
    Logger.debug(fn -> "#{@prefix}: count with params #{inspect([metric, value, tags])}" end)
  end

  @spec increment(any, any, any) :: any
  def increment(metric, value, tags) do
    Logger.debug(fn -> "#{@prefix}: increment with params #{inspect([metric, value, tags])}" end)
  end

  @spec decrement(any, any, any) :: any
  def decrement(metric, value, tags) do
    Logger.debug(fn -> "#{@prefix}: decrement with params #{inspect([metric, value, tags])}" end)
  end

  @spec gauge(any, any, any) :: any
  def gauge(metric, value, tags) do
    Logger.debug(fn -> "#{@prefix}: gauge with params #{inspect([metric, value, tags])}" end)
  end

  @spec histogram(any, any, any) :: any
  def histogram(metric, value, tags) do
    Logger.debug(fn -> "#{@prefix}: histogram with params #{inspect([metric, value, tags])}" end)
  end

  @spec timing(any, any, any) :: any
  def timing(metric, value, tags) do
    Logger.debug(fn -> "#{@prefix}: timing with params #{inspect([metric, value, tags])}" end)
  end

  @impl true
  def to_tags(tags_map), do: tags_map
end
