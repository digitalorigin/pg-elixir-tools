defmodule ElixirTools.IdempotencyControllerTest do
  use ExUnit.Case
  import Phoenix.ConnTest, only: [build_conn: 0]

  import Plug.Conn

  alias ElixirTools.IdempotencyController

  describe "idempotency_key/1" do
    setup do
      %{conn: build_conn()}
    end

    test "returns expected idempotency key value", %{conn: conn} do
      idempotency_key = "83cdc530-bb18-11e8-b568-0800200c9a66"
      updated_conn = put_req_header(conn, "idempotency-key", idempotency_key)

      assert {:ok, idempotency_key} == IdempotencyController.idempotency_key(updated_conn)
    end

    test "returns error if format is not UUID", %{conn: conn} do
      idempotency_key = "wrong_format_here"
      updated_conn = put_req_header(conn, "idempotency-key", idempotency_key)

      assert {:error, :wrong_format_idempotency_key} ==
               IdempotencyController.idempotency_key(updated_conn)
    end

    test "returns nil when idempotency key is missing", %{conn: conn} do
      assert {:ok, nil} == IdempotencyController.idempotency_key(conn)
    end
  end
end
