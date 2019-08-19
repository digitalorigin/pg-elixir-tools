defmodule ElixirTools.Events.EventHandlerTest do
  use ExUnit.Case, async: true

  alias ElixirTools.Events.{EventHandler, Event}

  setup do
    payload = %{
      amount: 1,
      charge_id: "charge_id",
      created_at: "created_at",
      payment_method_id: "payment_method_id",
      type: :card
    }

    event = %Event{
      name: "CHARGE_CREATED",
      payload: payload,
      version: "1.0.0",
      event_id_seed: "22833003-fb25-4961-8373-f01da28ec820"
    }

    %{payload: payload, event: event}
  end

  describe "create/3" do
    test "event is created as expected", %{payload: payload, event: event} do
      event_name = "CHARGE_CREATED"
      event_id_seed = "22833003-fb25-4961-8373-f01da28ec820"

      assert event == EventHandler.create(event_name, payload, event_id_seed)
      assert :ok == Event.validate(event)
    end
  end

  describe "create/4" do
    test "event is created as expected", %{payload: payload, event: event} do
      event_name = "CHARGE_CREATED"
      event_id_seed = "22833003-fb25-4961-8373-f01da28ec820"
      event_id_seed_optional = "event_id_seed_optional"
      occurred_at = Timex.now()

      optional_params = [
        {:event_id_seed_optional, "event_id_seed_optional"},
        {:occurred_at, occurred_at}
      ]

      event = %{event | event_id_seed_optional: event_id_seed_optional, occurred_at: occurred_at}

      assert event ==
               EventHandler.create(event_name, payload, event_id_seed, optional_params)

      assert :ok == Event.validate(event)
    end

    test "if event_id_seed_optional is nil - it's replaced with empty string", %{payload: payload} do
      event_name = "CHARGE_CREATED"
      event_id_seed = "22833003-fb25-4961-8373-f01da28ec820"

      optional_params = [
        {:occurred_at, Timex.now()}
      ]

      assert %{event_id_seed_optional: ""} =
               EventHandler.create(event_name, payload, event_id_seed, optional_params)
    end
  end

  describe "publish/2" do
    defmodule TaskSupervisorFake do
      use ElixirTools.ContractImpl, module: Task.Supervisor
      @impl true
      def async_nolink(_, function) do
        send(self(), :start)

        function.()
      end
    end

    defmodule EventFakeOk do
      use ElixirTools.ContractImpl, module: ElixirTools.Events.Event
      @impl true
      def publish(event) do
        send(self(), {:publish, event})

        :ok
      end
    end

    defmodule EventFakeFail do
      use ElixirTools.ContractImpl, module: ElixirTools.Events.Event
      @impl true
      def publish(event) do
        send(self(), {:publish, event})

        {:error,
         %RuntimeError{message: "sns not supported in region eu-north-1 for partition aws"}}
      end
    end

    defmodule TelemetryFake do
      def execute(event_name, measurements) do
        send(self(), {:telemetry_execute, %{event_name: event_name, measurements: measurements}})
      end
    end

    test "event is published as expected", %{event: event} do
      opts = [{:task_supervisor_module, TaskSupervisorFake}, {:event_module, EventFakeOk}]

      assert :ok == EventHandler.publish(event, opts)

      assert_received(:start)
      assert_received({:publish, ^event})
    end

    test "event publishing call returns error", %{event: event} do
      opts = [
        {:task_supervisor_module, TaskSupervisorFake},
        {:event_module, EventFakeFail},
        {:telemetry_module, TelemetryFake}
      ]

      assert :ok == EventHandler.publish(event, opts)

      assert_received(:start)
      assert_received({:publish, ^event})
    end

    test "if event not publish telemtry metric is sent", %{event: event} do
      opts = [
        {:task_supervisor_module, TaskSupervisorFake},
        {:event_module, EventFakeFail},
        {:telemetry_module, TelemetryFake}
      ]

      assert :ok == EventHandler.publish(event, opts)

      expected_reason =
        "%RuntimeError{message: \"sns not supported in region eu-north-1 for partition aws\"}"

      expected_error_info = event |> Map.from_struct() |> Map.put(:reason, expected_reason)

      assert_received(
        {:telemetry_execute,
         %{
           event_name: [:do_elixir_tools, :events, :not_sent],
           measurements: %{error_info: ^expected_error_info}
         }}
      )
    end

    test "save event to DB if it was not published", %{event: event} do
      defmodule FakeNotSentEvent do
        use ElixirTools.ContractImpl, module: ElixirTools.Events.NotSentEvent

        def create!(params) do
          send(self(), {:create_not_sent_event, params})
        end
      end

      opts = [
        {:task_supervisor_module, TaskSupervisorFake},
        {:event_module, EventFakeFail},
        {:not_sent_event_module, FakeNotSentEvent}
      ]

      assert :ok == EventHandler.publish(event, opts)

      assert_received(
        {:create_not_sent_event,
         %{
           content:
             "{\"event_id_seed\":\"22833003-fb25-4961-8373-f01da28ec820\",\"event_id_seed_optional\":\"\",\"name\":\"CHARGE_CREATED\",\"occurred_at\":null,\"payload\":{\"amount\":1,\"charge_id\":\"charge_id\",\"created_at\":\"created_at\",\"payment_method_id\":\"payment_method_id\",\"type\":\"card\"},\"reason\":\"%RuntimeError{message: \\\"sns not supported in region eu-north-1 for partition aws\\\"}\",\"version\":\"1.0.0\"}"
         }}
      )
    end
  end
end
