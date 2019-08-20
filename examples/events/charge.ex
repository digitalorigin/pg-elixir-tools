defmodule Examples.Events.Charge do
  @moduledoc """
  This module contains an example of events related to a charge.
  """

  alias ElixirTools.Events.Event

  @charge_created "CHARGE_CREATED"
  @charge_confirmed "CHARGE_CONFIRMED"

  @spec charge_created(map) :: :ok | {:error, term}
  def charge_created(params) do
    payload = %{
      charge_id: params[:charge_id],
      created_at: params[:created_at],
      amount: params[:amount],
      type: params[:type],
      payment_method_id: params[:payment_method_id]
    }

    @charge_created
    |> EventHandler.create(payload, charge.id)
    |> EventHandler.publish()
  end

  @spec charge_confirmed(map) :: :ok | {:error, term}
  def charge_confirmed(params) do
    if Events.send_operation_confirmed_event?(params[:status]) do
      payload = %{
        charge_id: params[:charge_id],
        confirmed_at: params[:confirmed_at],
        status: params[:status],
        metadata: params[:metadata]
      }

      optional_params = [
        {:event_id_seed_optional, DateTime.to_string(params[:status_inserted_at])}
      ]

      @charge_confirmed
      |> EventHandler.create(payload, params[:charge_id], optional_params)
      |> EventHandler.publish()
    end

    :ok
  end
end
