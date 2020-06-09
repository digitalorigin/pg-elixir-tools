defmodule ElixirTools.HttpClient.Adapter do
  @moduledoc """
  The adapter specifies a behaviour for implementing HttpClient adapters
  """

  @doc """
  Returns the base URI String for the HTTP endpoint of a specific adapter.
  """
  @callback base_uri() :: String.t()

  @doc """
  Returns the token for a specific request.
  """
  @callback default_headers() :: [tuple]

  @optional_callbacks [default_headers: 0]

  defmacro __using__(_) do
    quote do
      @behaviour ElixirTools.HttpClient.Adapter

      @impl true
      @spec default_headers :: [tuple]
      def default_headers, do: []

      defoverridable default_headers: 0
    end
  end
end
