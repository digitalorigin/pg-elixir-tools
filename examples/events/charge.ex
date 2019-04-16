defmodule Examples.Events.Charge do
  @moduledoc """
  This module contains an example of events related to a charge.
  """

  alias ElixirTools.Events.Event

  @charge_created "CHARGE_CREATED"
  @charge_requested "CHARGE_REQUESTED"

  @spec charge_created(map) :: :ok | {:error, term}
  def charge_created(params) do
    Event.publish(%Event{
      name: @charge_created,
      payload: %{
        charge_id: Map.fetch!(params, :charge_id),
        created_at: Map.fetch!(params, :created_at),
        amount: Map.fetch!(params, :amount),
        type: Map.fetch!(params, :type),
        payment_method_id: Map.fetch!(params, :payment_method_id)
      }
    })
  end

  @spec charge_requested(map) :: :ok | {:error, term}
  def charge_requested(params) do
    Event.publish(%Event{
      name: @charge_requested,
      payload: %{
        charge_id: Map.fetch!(params, :charge_id),
        requested_at: Map.fetch!(params, :requested_at),
        amount: Map.fetch!(params, :amount),
        type: Map.fetch!(params, :type),
        payment_method_id: Map.fetch!(params, :payment_method_id)
      }
    })
  end
end
