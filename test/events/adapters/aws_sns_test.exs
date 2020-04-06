defmodule ElixirTools.Events.Adapters.AwsSnsTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias ElixirTools.Events.Adapters.AwsSns

  defmodule FakeAwsSuccess do
    use ElixirTools.ContractImpl, module: ExAws

    @impl true
    def request(request, opts) do
      send(self(), [:ex_aws_success, request, opts])
      {:ok, %{status_code: 200}}
    end
  end

  defmodule FakeAwsError do
    use ElixirTools.ContractImpl, module: ExAws

    @impl true
    def request(request, opts) do
      send(self(), [:ex_aws_error, request, opts])
      {:ok, %{status_code: 400}}
    end
  end

  defmodule FakeSnsSuccess do
    use ElixirTools.ContractImpl, module: ExAws.SNS

    @impl true
    def publish(message, _opts) do
      send(self(), [:sns_success, message])
      :mocked
    end
  end

  setup do
    valid_event = %{
      id: "af7eae51-f47e-4ddb-a274-33037e17df6e",
      action: "EVENT_ACTION",
      group: "EVENT_GROUP",
      occurred_at: "2020-01-02T00:00:00.000Z",
      version: "1.0.0",
      payload: %{data: "data"}
    }

    %{valid_event: valid_event}
  end

  test "when event.occurred_at sent assert that it's used", context do
    opts = [
      aws_module: FakeAwsSuccess,
      sns_module: FakeSnsSuccess,
      topic: "topic",
      group: "group",
      default_region: "region"
    ]

    occurred_at = Timex.to_datetime({{2015, 6, 29}, {4, 44, 44}}, "Etc/UTC")
    event = %{context.valid_event | occurred_at: occurred_at}

    assert AwsSns.publish(event, opts) == :ok

    assert_received [
      :sns_success,
      "{\"action\":\"EVENT_ACTION\",\"group\":\"EVENT_GROUP\",\"id\":\"af7eae51-f47e-4ddb-a274-33037e17df6e\",\"occurred_at\":\"2015-06-29T04:44:44Z\",\"payload\":{\"data\":\"data\"},\"version\":\"1.0.0\"}"
    ]

    assert_received [:ex_aws_success, _, _]
  end

  test "when aws returns the expected reply", context do
    opts = [
      aws_module: FakeAwsSuccess,
      sns_module: FakeSnsSuccess,
      topic: "topic",
      group: "group",
      default_region: "region"
    ]

    assert AwsSns.publish(context.valid_event, opts) == :ok
    assert_received [:sns_success, _]
    assert_received [:ex_aws_success, _, _]
  end

  test "when aws returns unexpected reply", context do
    opts = [
      aws_module: FakeAwsError,
      sns_module: FakeSnsSuccess,
      topic: "topic",
      group: "group",
      default_region: "region"
    ]

    log =
      capture_log(fn ->
        assert {:error, {:unexpected_result, _}} = AwsSns.publish(context.valid_event, opts)
      end)

    assert log =~ "Unexpected result from AWS: {:ok, %{status_code: 400}}"

    assert_received [:sns_success, _]
    assert_received [:ex_aws_error, _, _]
  end
end
