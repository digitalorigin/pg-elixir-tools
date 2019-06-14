defmodule ElixirTools.JsonApi.Controller do
  @moduledoc """
  Works together with the `JsonApi`. The JSON API expects a validated request and converts the
  controller into a Json Api Controller by passing only the validated parameters using
  `JaSerializer`.

  Allows two `action_name` calls:
  1. `action_name/2`. Calls the action name with the params: `conn, json_api_params`
  2. `action_name/3`. To keep access to original parameter object it will call
                      `conn, phoenix_params, json_api_params`

  Example:
  ```
  defmodule Controller do
    use MyPhoenixWeb, :controller
    use ElixirTools.JsonApi.Controller

    def my_method(conn, json_params), do: conn
    def my_method(conn, phoenix_params, json_params), do: conn
  end
  ```
  """

  @type params :: map

  defmacro __using__(_) do
    quote do
      @spec action(Plug.Conn.t(), any) :: Plug.Conn.t()
      def action(conn, _) do
        json_api_params = Map.get(conn.assigns, :json_api_params, %{})

        args =
          if function_exported?(__MODULE__, action_name(conn), 2) do
            [conn, json_api_params]
          else
            [conn, conn.params, json_api_params]
          end

        apply(__MODULE__, action_name(conn), args)
      end

      defoverridable action: 2
    end
  end
end
