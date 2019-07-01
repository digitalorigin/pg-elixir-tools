defmodule ElixirTools.Metrix.Supervisor do
  @moduledoc false

  use Supervisor

  @typep child :: Supervisor.child_spec() | module | {module, []}

  @recurrent_metrics Application.get_env(:pagantis_elixir_tools, ElixirTools.Metrix)[
                       :recurrent_metrics
                     ]

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
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
end
