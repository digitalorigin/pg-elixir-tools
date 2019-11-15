defmodule ElixirTools.MultiLevelRequestLogger.PlugTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias ElixirTools.MultiLevelRequestLogger.Plug, as: MultiLevelRequestLoggerPlug

  describe "init/1" do
    test "returns the opts" do
      assert MultiLevelRequestLoggerPlug.init([:opt1, :opt2]) == [:opt1, :opt2]
    end
  end

  describe "call/2 without config" do
    setup do
      opts = []

      %{opts: opts, conn: %Plug.Conn{}}
    end

    test "use default level", context do
      conn = %{context.conn | request_path: "/request_path"}

      log = capture_log(fn -> MultiLevelRequestLoggerPlug.call(conn, context.opts) end)

      assert log =~ "[info]  GET /request_path"
    end

    test "when an empty conn struct is given, use default level", context do
      log = capture_log(fn -> MultiLevelRequestLoggerPlug.call(%Plug.Conn{}, context.opts) end)

      assert log =~ "[info]  GET"
    end
  end

  describe "call/2 with config" do
    setup do
      opts = []

      on_exit(fn ->
        Application.delete_env(:pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger)
      end)

      %{opts: opts, conn: %Plug.Conn{request_path: "/request_path"}}
    end

    test "default level is taken", context do
      Application.put_env(:pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger,
        default_log_level: :debug
      )

      log = capture_log(fn -> MultiLevelRequestLoggerPlug.call(context.conn, context.opts) end)

      assert log =~ "[debug] GET /request_path"

      Application.put_env(:pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger,
        default_log_level: :warn
      )

      log = capture_log(fn -> MultiLevelRequestLoggerPlug.call(context.conn, context.opts) end)

      assert log =~ "[warn]  GET /request_path"
    end

    test "default level is invalid", context do
      Application.put_env(:pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger,
        default_log_level: :invalid
      )

      log = capture_log(fn -> MultiLevelRequestLoggerPlug.call(context.conn, context.opts) end)

      assert log =~ "[error] Wrong default log level configured in configuration. Using default."
      assert log =~ "[info]  GET /request_path"
    end

    test "default is overriden when set in the config", context do
      Application.put_env(:pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger,
        default_log_level: :debug,
        path_log_level: %{"/request_path" => :error}
      )

      log = capture_log(fn -> MultiLevelRequestLoggerPlug.call(context.conn, context.opts) end)

      assert log =~ "[error] GET /request_path"
    end

    test "when invalid config option is set", context do
      Application.put_env(:pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger,
        path_log_level: %{"/request_path" => :invalid},
        default_log_level: :error
      )

      log = capture_log(fn -> MultiLevelRequestLoggerPlug.call(context.conn, context.opts) end)

      assert log =~ "[warn]  Invalid log level for /request_path. Using default (error)"
      assert log =~ "[error] GET /request_path"
    end
  end
end
