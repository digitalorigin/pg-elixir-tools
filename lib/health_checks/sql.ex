defmodule ElixirTools.HealthChecks.Sql do
  @moduledoc """
  The Sql healthcheck verifies that the ecto repos are available and ready for handling requests
  """

  require Logger

  @behaviour ElixirTools.HealthChecks.HealthCheck

  @type ready_params :: %{
          repos: [module]
        }

  @impl true
  def status(params, opts \\ []) do
    sql_module = opts[:sql_module] || Ecto.Adapters.SQL

    params
    |> Map.fetch!(:repos)
    |> Enum.each(&sql_module.query!(&1, "SELECT 1"))

    :ok
  rescue
    exception ->
      Logger.error(fn -> inspect(exception) end)
      {:error, exception}
  end
end
