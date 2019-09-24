defmodule Metrix.Adapters.LogTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog
  import ElixirTools.MetrixHelper

  alias ElixirTools.Metrix
  alias ElixirTools.Metrix.Adapters.Log

  setup :start_supervisor

  setup do
    Logger.configure(level: :debug)
    :ok
  end

  test "connect" do
    log_message = capture_log(fn -> Log.connect() end)
    assert log_message =~ "Statsd log adapter: Connect"
  end

  @methods ~w(count increment decrement gauge histogram timing)
  Enum.each(@methods, fn method_name ->
    test "#{method_name} logs the correct message through Metrix" do
      method = String.to_atom(unquote(method_name))
      metric = "my_metric"
      value = "my_value"
      tags = %{tag_1: "tag_1", tag_2: "tag_2"}
      args = [metric, value, tags, [adapter: Log]]

      log_message =
        capture_log(fn ->
          apply(Metrix, method, args)
          :sys.get_state(Metrix)
        end)

      assert log_message =~
               "Statsd log adapter: #{to_string(method)} with params [\"my_metric\", \"my_value\", %{default_tag: \"1\", other_default_tag: \"2\", tag_1: \"tag_1\", tag_2: \"tag_2\"}]"
    end
  end)
end
