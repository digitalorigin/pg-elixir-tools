defmodule ElixirTools.IntegerHelperTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias ElixirTools.IntegerHelper

  defmodule FakeTelemetry do
    def execute(key, event) do
      send(self(), {:telemetry_execute, [key, event]})
    end
  end

  describe "ensure_integer/3" do
    setup do
      %{default_value: -1}
    end

    test "returns the integer when the value is an integer", context do
      key = "my_key"
      value = 1

      assert IntegerHelper.ensure_integer(key, value, context.default_value) == 1
    end

    test "returns the integer when the value is a string", context do
      key = "my_key"
      value = "1"

      assert IntegerHelper.ensure_integer(key, value, context.default_value) == 1
    end

    test "returns the default when the value is not parseable and warns", context do
      not_parseable = [nil, 0.0, false, %{}, {}, :atom, MapSet.new()]
      key = "my_key"

      for value <- not_parseable do
        log =
          capture_log(fn ->
            result = IntegerHelper.ensure_integer(key, value, context.default_value)
            assert result == context.default_value
          end)

        assert log =~ "#{inspect(value)} is not valid for my_key"
      end
    end

    test "sends telemetry metric when value is not parsable to integer", context do
      key = "my_key"
      value = :not_integer

      IntegerHelper.ensure_integer(key, value, context.default_value,
        telemetry_module: FakeTelemetry
      )

      expected_key = [:pagantis_elixir_tools, :ensure_integer, :not_valid]
      expected_event = %{error_info: ":not_integer is not valid for my_key. Using default -1"}

      assert_received({:telemetry_execute, [^expected_key, ^expected_event]})
    end

    test "when default nor value is an integer, raise an error" do
      key = "my_key"
      value = :not_integer
      default = :not_integer

      assert_raise(RuntimeError, "Default has to be an integer. Given: :not_integer", fn ->
        IntegerHelper.ensure_integer(key, value, default)
      end)
    end
  end
end
