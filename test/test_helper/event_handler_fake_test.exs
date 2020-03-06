defmodule ElixirTools.TestHelper.EventHandlerFakeTest do
  use ExUnit.Case, async: true

  alias ElixirTools.TestHelper.EventHandlerFake
  alias ElixirTools.Events.Event

  describe "publish/2" do
    test "returns expected value and sends expected message" do
      assert EventHandlerFake.publish("event", "opts") == :ok
      assert_received {:publish_event, "event"}
    end
  end

  describe "create/3" do
    test "returns expected value and sends expected message" do
      event = %Event{name: "event_name", payload: "payload", event_id_seed: "event_id_seed"}
      assert EventHandlerFake.create("event_name", "payload", "event_id_seed") == event
      assert_received {:create_event, ["event_name", "payload", "event_id_seed"]}
    end
  end

  describe "create/4" do
    test "returns expected value and sends expected message" do
      optional_params = %{
        event_id_seed_optional: "event_id_seed_optional",
        occurred_at: "occurred_at",
        version: "1.42.0"
      }

      expected_event = %Event{
        name: "event_name",
        payload: "payload",
        event_id_seed: "event_id_seed",
        event_id_seed_optional: optional_params[:event_id_seed_optional],
        occurred_at: optional_params[:occurred_at],
        version: optional_params[:version]
      }

      assert EventHandlerFake.create("event_name", "payload", "event_id_seed", optional_params) ==
               expected_event

      assert_received {:create_event,
                       ["event_name", "payload", "event_id_seed", ^optional_params]}
    end

    test "if version was not set, use 1.0.0" do
      optional_params = %{occurred_at: "occurred_at"}
      event = EventHandlerFake.create("event_name", "payload", "event_id_seed", optional_params)
      assert event.version == "1.0.0"
    end
  end
end
