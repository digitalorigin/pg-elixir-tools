defmodule ElixirTools.Events.Adapters.AwsSns do
  @moduledoc """
  Functionality for pushing an event to SNS
  """

  require Logger

  @behaviour ElixirTools.Events.Publisher

  @typep publish_opt ::
           {:aws_module, module}
           | {:sns_module, module}
           | {:group, String.t()}
           | {:topic, String.t()}

  @impl true
  @spec publish(map, [publish_opt]) :: :ok | {:error, term}
  def publish(event, opts \\ []) do
    config = Application.get_env(:pagantis_elixir_tools, ElixirTools.Events)[:adapter_config]
    topic = opts[:topic] || Map.fetch!(config, :topic)
    default_region = opts[:default_region] || Map.fetch!(config, :default_region)
    sns_module = opts[:sns_module] || ExAws.SNS
    aws_module = opts[:aws_module] || ExAws

    event
    |> Jason.encode!()
    |> sns_module.publish(topic_arn: topic)
    |> aws_module.request(region: default_region)
    |> handle_publish
  end

  @spec handle_publish({:ok, map}) :: :ok | {:error, term}
  defp handle_publish({:ok, %{status_code: 200}}), do: :ok

  defp handle_publish(result) do
    Logger.warn(fn -> "Unexpected result from AWS: #{inspect(result)}" end)
    {:error, {:unexpected_result, result}}
  end
end
