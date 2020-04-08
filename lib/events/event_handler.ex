defmodule ElixirTools.Events.EventHandler do
  alias ElixirTools.Events.{Event, NotSentEvent}

  @type events_opt ::
          {:event_handler_module, module}
          | {:task_supervisor_module, module}
          | {:event_module, module}
          | {:not_sent_event_module, module}
          | {:telemetry_module, module}

  @typep event_schema :: map
  @callback send_event(any, [events_opt]) :: :ok
  @callback create(event_name, payload) :: Event.t()
  @callback publish(Event.t(), [events_opt]) :: :ok
  @callback publish(Event.t(), event_schema, [events_opt]) :: :ok

  @optional_callbacks send_event: 2,
                      create: 2,
                      publish: 2,
                      publish: 3

  @typep event_name :: String.t()
  @typep payload :: map
  @typep event_id_seed :: Ecto.UUID.t()

  @spec create(event_name, payload, event_id_seed) :: Event.t()
  def create(event_name, payload, event_id_seed) do
    %Event{name: event_name, payload: payload, event_id_seed: event_id_seed}
  end

  @typep create_optional ::
           {:event_id_seed_optional, String.t()}
           | {:occurred_at, DateTime.t()}
           | {:version, String.t()}
  @spec create(event_name, payload, event_id_seed, [create_optional]) :: Event.t()
  def create(event_name, payload, event_id_seed, create_optional) do
    event_id_seed_optional = create_optional[:event_id_seed_optional] || ""
    occurred_at = create_optional[:occurred_at]
    version = create_optional[:version] || "1.0.0"

    %Event{
      name: event_name,
      payload: payload,
      event_id_seed: event_id_seed,
      event_id_seed_optional: event_id_seed_optional,
      occurred_at: occurred_at,
      version: version
    }
  end

  @spec publish(Event.t(), [events_opt]) :: :ok
  def publish(event, opts) do
    task_supervisor_module = opts[:task_supervisor_module] || Task.Supervisor

    task_supervisor_module.async_nolink(ElixirTools.TaskSupervisor, fn ->
      publish_event_call(event, opts)
    end)

    :ok
  end

  @spec publish(Event.t(), event_schema, [events_opt]) :: :ok
  def publish(event, schema, opts) do
    task_supervisor_module = opts[:task_supervisor_module] || Task.Supervisor

    task_supervisor_module.async_nolink(ElixirTools.TaskSupervisor, fn ->
      publish_event_call(event, schema, opts)
    end)

    :ok
  end

  @spec publish_event_call(Event.t(), [events_opt]) :: :ok | :error
  def publish_event_call(event, opts) do
    event_module = opts[:event_module] || Event

    case event_module.publish_deprecated(event) do
      {:error, reason} -> handle_error(event, reason, opts)
      _ -> :ok
    end
  end

  @spec publish_event_call(Event.t(), event_schema, [events_opt]) :: :ok | :error
  defp publish_event_call(event, schema, opts) do
    event_module = opts[:event_module] || Event

    case event_module.publish(event, schema) do
      {:error, reason} -> handle_error(event, reason, opts)
      _ -> :ok
    end
  end

  @spec handle_error(Event.t(), String.t(), [events_opt]) :: :error
  defp handle_error(event, error_reason, opts) do
    telemetry_module = opts[:telemetry_module] || :telemetry
    not_sent_event_module = opts[:not_sent_event_module] || NotSentEvent

    error_info = event |> Map.from_struct() |> Map.put(:reason, inspect(error_reason))

    telemetry_module.execute(
      [:pagantis_elixir_tools, :events, :not_sent],
      %{error_info: error_info}
    )

    not_sent_event_module.create!(%{content: Jason.encode!(error_info)})

    :error
  end
end
