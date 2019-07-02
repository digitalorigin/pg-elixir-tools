defmodule ElixirTools.Metrix.PlugTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Plug, as: MetrixPlug

  setup do
    conn = %Plug.Conn{
      adapter: {Plug.Adapters.Cowboy.Conn, :...},
      assigns: %{},
      body_params: %{},
      cookies: %Plug.Conn.Unfetched{aspect: :cookies},
      halted: false,
      host: "localhost",
      method: "GET",
      params: %{},
      path_info: ["v1", "my_controller"],
      path_params: %{},
      port: 4000,
      private: %{
        PgPaymentsWeb.Router => {[], %{}},
        :phoenix_action => :my_method,
        :phoenix_controller => PgPaymentsWeb.MyController,
        :phoenix_endpoint => PgPaymentsWeb.Endpoint,
        :phoenix_layout => {PgPaymentsWeb.LayoutView, :app},
        :phoenix_pipelines => [:all],
        :phoenix_router => PgPaymentsWeb.Router,
        :phoenix_view => PgPaymentsWeb.MyView
      },
      query_params: %{},
      query_string: "",
      remote_ip: {127, 0, 0, 1},
      req_cookies: %Plug.Conn.Unfetched{aspect: :cookies},
      req_headers: [
        {"content-type", "application/json"},
        {"cache-control", "no-cache"},
        {"postman-token", "6c057259-ec19-4f59-9ce9-8e5eaa827764"},
        {"user-agent", "PostmanRuntime/7.3.0"},
        {"accept", "*/*"},
        {"host", "localhost:4000"},
        {"accept-encoding", "gzip, deflate"},
        {"connection", "keep-alive"}
      ],
      request_path: "//v1/my_controller",
      resp_body: [123, [[34, ["ping"], 34], 58, [34, ["pong"], 34]], 125],
      resp_cookies: %{},
      resp_headers: [
        {"content-type", "application/json; charset=utf-8"},
        {"cache-control", "max-age=0, private, must-revalidate"}
      ],
      scheme: :http,
      script_name: [],
      secret_key_base: nil,
      state: :set,
      status: 200
    }

    %{conn: conn}
  end

  describe "call/2" do
    defmodule MetricsLibrary do
      use ElixirTools.ContractImpl, module: ElixirTools.Metrix

      @impl true
      def timing(metric, value, tags \\ %{}) do
        send(self(), [:timing, metric, value, tags])
      end

      @impl true
      def increment(metric, value, tags \\ %{}) do
        send(self(), [:increment, metric, value, tags])
      end
    end

    setup %{conn: conn} do
      conn = MetrixPlug.call(conn, metrics_module: MetricsLibrary)

      %{conn: conn}
    end

    test "calls the metrics with the right tags", %{conn: conn} do
      [send_metrics] = conn.before_send

      expected_tags = %{
        action: "my_method",
        api_version: "v1",
        controller: "MyController",
        http_method: "GET",
        request_path: "/v1/my_controller",
        response_status_code: 200,
        response_status_code_class: "2xx"
      }

      send_metrics.(conn)

      assert_received([:timing, "request.timer", timing_value, timing_tags])
      assert_received([:increment, "request.status", 1, increment_tags])

      assert is_integer(timing_value)
      assert timing_tags == expected_tags
      assert increment_tags == expected_tags
    end
  end
end
