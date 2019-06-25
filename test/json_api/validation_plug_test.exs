defmodule ElixirTools.JsonApi.ValidationPlugTest do
  use ExUnit.Case

  import Phoenix.ConnTest, only: [build_conn: 0]

  alias ElixirTools.JsonApi.ValidationPlug
  alias ElixirTools.Fixture

  @json_api_basic Fixture.load_json!("json_api/valid")
  @check_body_methods ~w(POST PATCH DELETE PUT)

  setup do
    %{conn: build_conn()}
  end

  Enum.each(@check_body_methods, fn method ->
    describe "call/2 #{method}" do
      setup %{conn: conn} do
        conn = %{conn | params: @json_api_basic, method: unquote(method)}
        %{conn: conn}
      end

      test "valid json api body for method", %{conn: conn} do
        conn = ValidationPlug.call(conn, :ignored)

        assert conn.status == nil
      end

      test "body without data object", %{conn: conn} do
        conn = %{conn | params: Map.delete(conn.params, "data")}
        conn = ValidationPlug.call(conn, :ignored)

        assert conn.status == nil
      end

      test "data without a type is invalid", %{conn: conn} do
        conn = %{conn | params: %{"data" => Map.delete(conn.params["data"], "type")}}
        conn = ValidationPlug.call(conn, :ignored)

        assert conn.status == 400
      end

      test "data without attributes is invalid", %{conn: conn} do
        conn = %{conn | params: %{"data" => Map.delete(conn.params["data"], "attributes")}}
        conn = ValidationPlug.call(conn, :ignored)

        assert conn.status == 400
      end

      test "assigns the json_params", %{conn: conn} do
        conn = ValidationPlug.call(conn, :ignored)

        expected = %{
          "author_id" => "42",
          "body" => "The shortest article. Ever.",
          "created" => "2015-05-22T14:56:29.000Z",
          "id" => "1",
          "title" => "JSON API paints my bikeshed!",
          "type" => "articles",
          "updated" => "2015-05-22T14:56:28.000Z"
        }

        assert conn.assigns.json_api_params == expected
      end
    end
  end)

  describe "call/2 GET" do
    setup %{conn: conn} do
      conn = %{conn | method: "GET"}
      %{conn: conn}
    end

    test "valid for method without params", %{conn: conn} do
      conn = ValidationPlug.call(conn, :ignored)

      assert conn.status == nil
    end

    test "does not assign the json_params", %{conn: conn} do
      conn = ValidationPlug.call(conn, :ignored)

      assert Map.get(conn.assigns, :json_api_params) == nil
    end
  end
end
