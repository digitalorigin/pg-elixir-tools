defmodule ElixirTools.Metrix.Recurring.ErlangStatsTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Metrix.Recurring.ErlangStats

  describe "send/1" do
    defmodule MetricsAdapter do
      use ElixirTools.ContractImpl, module: ElixirTools.Metrix

      @impl true
      def gauge(metric, value, tags) do
        send(self(), [metric, value, tags])
      end
    end

    defmodule MetricsModule do
      defmodule Metric1 do
        @behaviour ElixirTools.Metrix.Recurring.ErlangStats.Metrics
        @impl true
        def measure, do: {:ok, "my_key_1", "my_value_1", %{tag_1: :tag_1}}
      end

      defmodule Metric2 do
        @behaviour ElixirTools.Metrix.Recurring.ErlangStats.Metrics
        @impl true
        def measure, do: {:ok, "my_key_2", "my_value_2", %{tag_1: :tag_2}}
      end

      def all, do: %{gauge: [Metric1, Metric2]}
    end

    test "sends the metrics to the adapter" do
      ErlangStats.send_metrics(
        metrics_adapter_module: MetricsAdapter,
        metrics_module: MetricsModule
      )

      expected_tags = %{tag_1: :tag_1}
      assert_received(["my_key_1", "my_value_1", ^expected_tags])

      expected_tags = %{tag_1: :tag_2}
      assert_received(["my_key_2", "my_value_2", ^expected_tags])
    end

    test "send metrics every second" do
      test_pid = self()

      task =
        Task.async(fn ->
          {:ok, nil} = ErlangStats.init(nil)

          receive do
            message -> send(test_pid, message)
          end
        end)

      Task.await(task, 1000)

      assert_received(:loop_send)
    end
  end
end
