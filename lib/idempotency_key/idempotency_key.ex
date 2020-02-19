defmodule ElixirTools.IdempotencyKey do
  @moduledoc """
  Provides functionality for idempotent controllers. Extract, verify format of idempotency keys.
  """

  import Plug.Conn

  alias Plug.Conn

  @type idempotency_key :: Ecto.UUID.t() | nil
  @typep error_format_check :: {:error, :wrong_idempotency_key}

  @doc """
  Extract idempotency key from header
  """
  @spec get(Conn.t()) :: {:ok, idempotency_key} | error_format_check
  def get(conn) do
    case get_req_header(conn, "idempotency-key") do
      [idempotency_key] -> check_format(idempotency_key)
      [] -> {:ok, nil}
    end
  end

  @spec check_format(idempotency_key) :: {:ok, idempotency_key} | error_format_check
  defp check_format(idempotency_key) do
    case Ecto.UUID.cast(idempotency_key) do
      :error -> {:error, :wrong_format_idempotency_key}
      {:ok, value} -> {:ok, value}
    end
  end
end
