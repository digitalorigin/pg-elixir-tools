defmodule ElixirTools.HttpClient.Adapter do
  @moduledoc """
  The adapter specifies a behaviour for implementing HttpClient adapters
  """

  @doc """
  Returns the base URI String for the HTTP endpoint of a specific adapter.
  """
  @callback base_uri() :: String.t()
end
