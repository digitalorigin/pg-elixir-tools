defmodule ElixirTools.JsonApi.ControllerTest do
  use ExUnit.Case

  defmodule ControllerImpl2 do
    use ElixirTools.JsonApi.Controller

    def action_name(_), do: :show

    def show(conn, json_params) do
      send(self(), {:show_2, [conn, json_params]})
    end
  end

  defmodule ControllerImpl3 do
    use ElixirTools.JsonApi.Controller

    def action_name(_), do: :show

    def show(conn, params, json_params) do
      send(self(), {:show_3, [conn, params, json_params]})
    end
  end

  setup do
    %{conn: %{assigns: %{json_api_params: %{json_api: true}}, params: %{phoenix_params: true}}}
  end

  describe "action/3" do
    test "when the method with arity 3 exist, use that one", context do
      ControllerImpl3.action(context.conn, nil)
      assert_received({:show_3, [conn, params, json_params]})
      assert conn == context.conn
      assert params == %{phoenix_params: true}
      assert json_params == %{json_api: true}
    end
  end

  describe "action/2" do
    test "when the method with arity 2 exist, use that one", context do
      ControllerImpl2.action(context.conn, nil)
      assert_received({:show_2, [conn, json_params]})
      assert conn == context.conn
      assert json_params == %{json_api: true}
    end

    test "when no parameters are set, use an empty map as JSON parameters" do
      conn = %{assigns: %{}}

      ControllerImpl2.action(conn, nil)
      assert_received({:show_2, [^conn, json_params]})
      assert json_params == %{}
    end
  end
end
