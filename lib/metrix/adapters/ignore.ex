defmodule ElixirTools.Metrix.Adapters.Ignore do
  @moduledoc """
  This adapter acts like metrics are sent, but it does not do anything
  """

  @behaviour ElixirTools.Metrix.Adapters.Adapter

  require Logger

  @spec connect() :: :ok
  def connect, do: :ok

  @spec count(any, any, any) :: :ok
  def count(_, _, _), do: :ok

  @spec increment(any, any, any) :: :ok
  def increment(_, _, _), do: :ok

  @spec decrement(any, any, any) :: :ok
  def decrement(_, _, _), do: :ok

  @spec gauge(any, any, any) :: :ok
  def gauge(_, _, _), do: :ok

  @spec histogram(any, any, any) :: :ok
  def histogram(_, _, _), do: :ok

  @spec timing(any, any, any) :: :ok
  def timing(_, _, _), do: :ok

  @impl true
  def to_tags(_), do: %{}
end
