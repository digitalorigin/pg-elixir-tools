defmodule ElixirTools.Metrix.Plug do
  @moduledoc """
  Sends phoenix metrics to the statsd adapter for request and response information
  """

  @behaviour Plug

  import Plug.Conn, only: [register_before_send: 2]

  alias ElixirTools.Metrix
  alias ElixirTools.Metrix.Plug.Tags
  alias Plug.Conn

  @timer_metric "request.timer"
  @http_status_metric "request.status"

  @unit :millisecond

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @spec call(Conn.t(), any) :: Conn.t()
  def call(conn, opts \\ []) do
    metrics_module = opts[:metrics_module] || Metrix
    start_time = :erlang.monotonic_time(@unit)

    register_before_send(conn, fn conn ->
      tags = tags(conn)
      duration = :erlang.monotonic_time(@unit) - start_time

      metrics_module.timing(@timer_metric, duration, tags)
      metrics_module.increment(@http_status_metric, 1, tags)

      conn
    end)
  end

  @spec tags(Conn.t()) :: map
  defp tags(conn) do
    %{
      controller: Tags.controller_name(conn),
      action: Tags.method_name(conn),
      http_method: conn.method,
      request_path: Tags.request_path(conn),
      api_version: Tags.api_version(conn),
      response_status_code: conn.status,
      response_status_code_class: Tags.response_status_code_class(conn)
    }
  end
end
