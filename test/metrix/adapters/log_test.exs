defmodule ElixirTools.Metrix.Adapters.LogTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias ElixirTools.Metrix.Adapters.Log

  setup do
    Logger.configure(level: :debug)
  end

  test "connect" do
    log_message = capture_log(&Log.connect/0)
    assert log_message =~ "Statsd log adapter: Connect"
  end

  @methods ~w(count increment decrement gauge histogram timing)
  Enum.each(@methods, fn method_name ->
    test "#{method_name} logs the correct message through ElixirTools.Metrix" do
      method = String.to_atom(unquote(method_name))
      metric = "my_metric"
      value = "my_value"
      tags = %{tag_1: "tag_1", tag_2: "tag_2"}
      args = [metric, value, tags, [adapter: Log]]

      log_message =
        capture_log(fn ->
          apply(ElixirTools.Metrix, method, args)
          :sys.get_state(ElixirTools.Metrix)
        end)

      assert log_message =~
               "Statsd log adapter: #{to_string(method)} with params [\"my_metric\", \"my_value\", %{default_tag: \"1\", other_default_tag: \"2\", tag_1: \"tag_1\", tag_2: \"tag_2\"}]"
    end
  end)
end
