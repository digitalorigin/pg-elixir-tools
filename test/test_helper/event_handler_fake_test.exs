defmodule ElixirTools.TestHelper.EventHandlerFakeTest do
  use ExUnit.Case, async: true

  alias ElixirTools.TestHelper.EventHandlerFake
  alias ElixirTools.Events.Event

  describe "set_version/2" do
    test "returns expected value and sends expected message" do
      event = %Event{name: "event_name", event_id_seed: "event_id_seed"}
      assert EventHandlerFake.set_version(event, "v1") == %{event | version: "v1"}
      assert_received {:set_event_version, [^event, "v1"]}
    end
  end

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
        occurred_at: "occurred_at"
      }

      event = %Event{
        name: "event_name",
        payload: "payload",
        event_id_seed: "event_id_seed",
        event_id_seed_optional: optional_params[:event_id_seed_optional],
        occurred_at: optional_params[:occurred_at]
      }

      assert EventHandlerFake.create("event_name", "payload", "event_id_seed", optional_params) ==
               event

      assert_received {:create_event,
                       ["event_name", "payload", "event_id_seed", ^optional_params]}
    end
  end
end
