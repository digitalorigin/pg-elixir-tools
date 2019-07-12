defmodule ElixirTools.Events.Adapters.AwsSnsTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias ElixirTools.Events.Adapters.AwsSns
  alias ElixirTools.Events.Event

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
    valid_event = %Event{
      name: "TEST_EVENT",
      event_id_seed: "016c25fd-70e0-56fe-9d1a-56e80fa20b82"
    }

    %{valid_event: valid_event}
  end

  test "when aws returns the expected reply", context do
    opts = [
      aws_module: FakeAwsSuccess,
      sns_module: FakeSnsSuccess,
      topic: "topic",
      group: "group",
      default_region: "region"
    ]

    assert :ok == AwsSns.publish(context.valid_event, opts)
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
