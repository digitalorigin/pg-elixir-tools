defmodule ElixirTools.Metrix.Supervisor do
  @moduledoc false

  use Supervisor

  require Logger

  @typep child :: Supervisor.child_spec() | module | {module, []}

  @recurrent_metrics Application.get_env(:pagantis_elixir_tools, ElixirTools.Metrix)[
                       :recurrent_metrics
                     ]

  @spec start_link(any) :: {:ok, pid} | {:error, term}
  def start_link(_ \\ []) do
    if metrix_enabled?() do
      Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    else
      Logger.info("Metrix did not start because it's disabled.")
      :ignore
    end
  end

  @impl true
  def init(:ok) do
    children =
      []
      |> add_metrix_child
      |> add_recurrent_metric_children

    Supervisor.init(children, strategy: :one_for_one)
  end

  @spec add_metrix_child([child]) :: [child]
  defp add_metrix_child(children), do: [{ElixirTools.Metrix, []} | children]

  @spec add_recurrent_metric_children([child]) :: [child]
  defp add_recurrent_metric_children(children), do: children ++ @recurrent_metrics

  @spec metrix_enabled? :: boolean
  defp metrix_enabled? do
    enabled_values = [nil, true, "true"]
    Application.get_env(:pagantis_elixir_tools, ElixirTools.Metrix)[:enabled] in enabled_values
  end
end
