defmodule ElixirTools.HealthChecks.HealthCheck do
  @moduledoc """
  The `HealthCheck` module specifies a behaviour for dealing with health checks.
  """

  @doc """
  Gets the status of a health check.
  """
  @callback status(map) :: :ok | {:error, term}
end
