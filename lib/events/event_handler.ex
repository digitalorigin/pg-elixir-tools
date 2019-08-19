defmodule ElixirTools.Events.EventHandler do
  alias ElixirTools.Events.{Event, NotSentEvent}

  @type events_opt ::
          {:event_handler_module, module}
          | {:task_supervisor_module, module}
          | {:event_module, module}
          | {:not_sent_event_module, module}
          | {:telemetry_module, module}
  @callback send_event(any, [events_opt]) :: :ok

  @callback create(event_name, payload) :: Event.t()
  @callback publish(Event.t(), [events_opt]) :: :ok

  @optional_callbacks send_event: 2,
                      create: 2,
                      publish: 2

  @typep event_name :: String.t()
  @typep payload :: map
  @typep event_id_seed :: Ecto.UUID.t()
  @typep event_id_seed_optional :: String.t()

  @spec create(event_name, payload, event_id_seed) :: Event.t()
  def create(event_name, payload, event_id_seed) do
    %Event{name: event_name, payload: payload, event_id_seed: event_id_seed}
  end

  @typep create_optional ::
           {:event_id_seed_optional, event_id_seed_optional}
           | {:occurred_at, DateTime.t()}
  @spec create(event_name, payload, event_id_seed, [create_optional]) :: Event.t()
  def create(event_name, payload, event_id_seed, create_optional) do
    event_id_seed_optional = create_optional[:event_id_seed_optional] || ""
    occurred_at = create_optional[:occurred_at]

    %Event{
      name: event_name,
      payload: payload,
      event_id_seed: event_id_seed,
      event_id_seed_optional: event_id_seed_optional,
      occurred_at: occurred_at
    }
  end

  @spec publish(Event.t(), [events_opt]) :: :ok
  def publish(event, opts) do
    task_supervisor_module = opts[:task_supervisor_module] || Task.Supervisor

    task_supervisor_module.async_nolink(PgPayments.TaskSupervisor, fn ->
      publish_event_call(event, opts)
    end)

    :ok
  end

  @spec publish_event_call(Event.t(), [events_opt]) :: :ok | :error
  def publish_event_call(event, opts) do
    event_module = opts[:event_module] || Event
    not_sent_event_module = opts[:not_sent_event_module] || NotSentEvent
    telemetry_module = opts[:telemetry_module] || :telemetry

    case event_module.publish(event) do
      {:error, reason} ->
        error_info = event |> Map.from_struct() |> Map.put(:reason, inspect(reason))

        telemetry_module.execute([:do_elixir_tools, :events, :not_sent], %{error_info: error_info})

        not_sent_event_module.create!(%{content: Jason.encode!(error_info)})
        :error

      _ ->
        :ok
    end
  end
end
