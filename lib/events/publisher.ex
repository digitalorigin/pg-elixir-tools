defmodule ElixirTools.Events.Publisher do
  @moduledoc """
  The `Publisher` defines the behaviour to be implemented on adapter that implement the publishing
  logic to AWS, RabbitMQ or any other publishing method.
  """

  @doc """
  The publish method publishes an event to an adapter.
  """
  @callback publish(message :: map, opts :: []) :: :ok | {:error, term}
end
