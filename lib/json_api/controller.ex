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

  import Ecto.Changeset, only: [apply_changes: 1, traverse_errors: 2]
  import Phoenix.Controller, only: [put_view: 2, render: 3]
  import Plug.Conn

  alias __MODULE__
  alias Plug.Conn

  @error_view Application.get_env(:pagantis_elixir_tools, Controller)[:error_view]

  @type params :: map
  @type idempotency_key :: Ecto.UUID.t() | nil
  @typep error :: any

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

  @spec bad_input(Conn.t(), error) :: Conn.t()
  def bad_input(conn, error \\ "Bad Request"), do: do_error(conn, :bad_request, error)

  @spec not_found(Conn.t(), error) :: Conn.t()
  def not_found(conn, error \\ "Not Found"), do: do_error(conn, :not_found, error)

  @spec http_timeout(Conn.t(), error) :: Conn.t()
  def http_timeout(conn, error \\ "Request Timeout"), do: do_error(conn, :request_timeout, error)

  @spec unprocessable_entity(Conn.t(), error) :: Conn.t()
  def unprocessable_entity(conn, error \\ "Unprocessable Entity"),
    do: do_error(conn, :unprocessable_entity, error)

  @spec server_error(Conn.t(), error) :: Conn.t()
  def server_error(conn, error), do: do_error(conn, :internal_server_error, error)

  @spec validate_params(map, module) :: {:ok, struct} | {:error, {:bad_request, map}}
  def validate_params(params, schema) do
    changeset = schema.changeset(params)

    case changeset.valid? do
      true -> {:ok, apply_changes(changeset)}
      false -> {:error, {:bad_request, traverse_errors(changeset, & &1)}}
    end
  end

  @spec do_error(Conn.t(), Conn.status(), error) :: Conn.t()
  defp do_error(conn, http_code, error) do
    conn
    |> put_status(http_code)
    |> put_view(@error_view)
    |> render("#{http_code}.json-api", error: error)
    |> halt
  end
end
