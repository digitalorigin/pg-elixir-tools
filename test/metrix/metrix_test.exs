defmodule ElixirTools.Metrix.ElixirTools.MetrixTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias ElixirTools.Metrix
  alias ElixirTools.Metrix.Adapters

  defmodule FailAdapter do
    @behaviour ElixirTools.Metrix.Adapters.Adapter

    def increment(_, _, _) do
      raise "BOOM"
    end

    @impl true
    def to_tags(tags) do
      tags
    end
  end

  setup do
    Metrix.Supervisor.start_link()
    Logger.configure(level: :debug)
    default_tags = Application.get_env(:pagantis_elixir_tools, ElixirTools.Metrix)[:default_tags]

    %{default_tags: default_tags}
  end

  @methods ~w(count increment decrement gauge histogram timing)
  Enum.each(@methods, fn method_name ->
    test "#{method_name} calls adapter with the right args", context do
      method_name = unquote(method_name)
      method = String.to_atom(method_name)
      metric = "my_metric"
      value = "my_value"
      tags = %{tag_1: "tag_1", tag_2: "tag_2"}
      args = [metric, value, tags, [adapter_module: Adapters.Log]]

      log_message =
        capture_log(fn ->
          assert :ok == apply(ElixirTools.Metrix, method, args)
          await_execution()
        end)

      expected_tags = Map.merge(tags, context.default_tags)

      assert log_message =~
               "Statsd log adapter: #{method_name} with params [\"my_metric\", " <>
                 "\"my_value\", #{inspect(expected_tags)}]"
    end
  end)

  test "when the adapter throws an error", context do
    tags = %{my_tag: "my_value"}

    log_message =
      capture_log(fn ->
        ElixirTools.Metrix.increment("my.metric", 15, tags, adapter_module: FailAdapter)
        await_execution()
      end)

    expected_tags = Map.merge(tags, context.default_tags)

    assert log_message =~
             "Metric [\"my.metric\", 15, #{inspect(expected_tags)}] not sent: %RuntimeError{message: \"BOOM\"}"
  end

  describe "init/1" do
    setup do
      :ets.new(:supervisor_crash, [:named_table, :public])

      %{}
    end

    test "when connecting fails log message and retry" do
      defmodule CrashAdapter do
        @ets_table :supervisor_crash

        def connect() do
          case :ets.lookup(@ets_table, "first_try") do
            [] ->
              :ets.insert(@ets_table, {"first_try", "1"})
              raise "foo"

            _ ->
              :ets.delete(@ets_table, "first_try")
              :ok
          end
        end
      end

      log_message =
        capture_log(fn -> ElixirTools.Metrix.init(adapter_module: CrashAdapter, sleep_ms: 1) end)

      assert log_message =~
               "Could not connect to adapter: %RuntimeError{message: \"foo\"}. Retry in 1 ms"
    end
  end

  describe "handle_cast/2 send_metric" do
    test "when succeeds a debug message is logged" do
      args = ["my.metric", 15, %{}]

      log_message =
        capture_log(fn ->
          GenServer.cast(
            ElixirTools.Metrix,
            {:send_metric, :increment, args, adapter_module: Adapters.Log}
          )

          await_execution()
        end)

      assert log_message =~
               "[debug] Statsd log adapter: increment with params [\"my.metric\", 15, %{}]"
    end

    test "when the adapter raises an error, log a message" do
      args = ["my.metric", 15, %{}]

      log_message =
        capture_log(fn ->
          GenServer.cast(
            ElixirTools.Metrix,
            {:send_metric, :increment, args, adapter_module: FailAdapter}
          )

          await_execution()
        end)

      assert log_message =~
               "Metric [\"my.metric\", 15, %{}] not sent: %RuntimeError{message: \"BOOM\"}"
    end
  end

  defp await_execution() do
    :sys.get_state(ElixirTools.Metrix)
  end
end
