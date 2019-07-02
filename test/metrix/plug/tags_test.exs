defmodule ElixirTools.Metrix.Plug.TagsTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Plug.Tags

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
      path_info: ["status", "elb_ping"],
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
        :phoenix_view => PgPaymentsWeb.StatusView
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
      request_path: "//status/elb_ping",
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

  describe "controller_name/1" do
    test "returns the controller name", context do
      assert Tags.controller_name(context.conn) == "MyController"
    end

    test "returns nil if not set", context do
      conn = %{context.conn | private: Map.delete(context.conn.private, :phoenix_controller)}
      assert Tags.controller_name(conn) == nil
    end
  end

  describe "method_name/1" do
    test "returns the controller method name", context do
      assert Tags.method_name(context.conn) == "my_method"
    end

    test "returns nil if not set", context do
      conn = %{context.conn | private: Map.delete(context.conn.private, :phoenix_action)}
      assert Tags.method_name(conn) == nil
    end
  end

  describe "response_status_code_class/1" do
    test "returns the right code class", context do
      conn = %{context.conn | status: 400}
      assert Tags.response_status_code_class(conn) == "4xx"
    end
  end

  describe "api_version" do
    test "returns nil if the version is not specified", context do
      conn = %{context.conn | path_info: ["status", "elb_ping"]}
      assert Tags.api_version(conn) == nil
    end

    test "returns version if the version if specified", context do
      conn = %{context.conn | path_info: ["v1", "charges"]}
      assert Tags.api_version(conn) == "v1"
    end
  end

  describe "request_path" do
    test "removes extra slashes", context do
      conn = %{context.conn | request_path: "//status/elb_ping"}
      assert Tags.request_path(conn) == "/status/elb_ping"
    end
  end
end
