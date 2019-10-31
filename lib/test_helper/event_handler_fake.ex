defmodule ElixirTools.TestHelper.EventHandlerFake do
  use ElixirTools.ContractImpl, module: ElixirTools.Events.EventHandler

  alias ElixirTools.Events.Event

  @impl true
  def publish(event, _) do
    send(self(), {:publish_event, event})

    :ok
  end

  @impl true
  def create(event_name, payload, event_id_seed) do
    send(self(), {:create_event, [event_name, payload, event_id_seed]})

    %Event{name: event_name, payload: payload, event_id_seed: event_id_seed}
  end

  @impl true
  @spec create(any, any, any, nil | keyword | map) :: ElixirTools.Events.Event.t()
  def create(event_name, payload, event_id_seed, optional_params) do
    send(self(), {:create_event, [event_name, payload, event_id_seed, optional_params]})

    %Event{
      name: event_name,
      payload: payload,
      event_id_seed: event_id_seed,
      event_id_seed_optional: optional_params[:event_id_seed_optional],
      occurred_at: optional_params[:occurred_at]
    }
  end
end
