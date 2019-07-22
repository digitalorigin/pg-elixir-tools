defmodule ElixirTools.Events.Adapters.AwsSns do
  @moduledoc """
  Functionality for pushing an event to SNS
  """

  require Logger

  alias ElixirTools.Events.Event

  @behaviour ElixirTools.Events.Publisher

  @typep publish_opt ::
           {:aws_module, module}
           | {:sns_module, module}
           | {:uuid_module, module}
           | {:group, String.t()}
           | {:topic, String.t()}

  @impl true
  @spec publish(Event.t(), [publish_opt]) :: :ok | {:error, term}
  def publish(event, opts \\ []) do
    config = Application.get_env(:pagantis_elixir_tools, ElixirTools.Events)[:adapter_config]
    topic = opts[:topic] || Map.fetch!(config, :topic)
    default_region = opts[:default_region] || Map.fetch!(config, :default_region)
    sns_module = opts[:sns_module] || ExAws.SNS
    aws_module = opts[:aws_module] || ExAws

    event
    |> add_envelope(opts)
    |> Jason.encode!()
    |> sns_module.publish(topic_arn: topic)
    |> aws_module.request(region: default_region)
    |> handle_publish
  end

  @spec add_envelope(Event.t(), [publish_opt]) :: map
  defp add_envelope(event, opts) do
    uuid_module = opts[:uuid_module] || UUID

    config = Application.get_env(:pagantis_elixir_tools, ElixirTools.Events)[:adapter_config]
    group = opts[:group] || Map.fetch!(config, :group)

    uuid_seed_2 = "#{event.name}-#{event.version}-#{event.event_id_seed_optional}"
    id = uuid_module.uuid5(event.event_id_seed, uuid_seed_2)

    occurred_at = event.occurred_at || Timex.now()
    occurred_at = Timex.format!(occurred_at, "{ISO:Extended:Z}")

    %{
      id: id,
      action: String.upcase(event.name),
      group: group,
      occurred_at: occurred_at,
      version: event.version,
      payload: event.payload
    }
  end

  @spec handle_publish({:ok, map}) :: :ok | {:error, term}
  defp handle_publish({:ok, %{status_code: 200}}), do: :ok

  defp handle_publish(result) do
    Logger.warn(fn -> "Unexpected result from AWS: #{inspect(result)}" end)
    {:error, {:unexpected_result, result}}
  end
end
