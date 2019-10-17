defmodule ElixirTools.Events.EventTest do
  use ExUnit.Case

  alias ElixirTools.Events.Event

  defmodule FakeAdapterError do
    @behaviour ElixirTools.Events.Publisher
    @impl true
    def publish(_, _ \\ []), do: raise("ERROR")
  end

  defmodule FakeAdapterSuccess do
    @behaviour ElixirTools.Events.Publisher
    @impl true
    def publish(_, _ \\ []), do: :ok
  end

  setup do
    valid_event = %Event{
      name: "TEST_EVENT",
      event_id_seed: "016c25fd-70e0-56fe-9d1a-56e80fa20b82"
    }

    %{valid_event: valid_event}
  end

  describe "publish/2" do
    test "returns :ok when it's succesfully sent", context do
      assert Event.publish(context.valid_event, FakeAdapterSuccess) == :ok
    end

    test "returns error when adapter throws error", context do
      assert Event.publish(context.valid_event, FakeAdapterError) ==
               {:error, %RuntimeError{message: "ERROR"}}
    end

    test "returns error when version is not a string", context do
      event = %{context.valid_event | version: 1}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a string with a version"}
    end

    test "returns error when version is not having major.minor.fix format", context do
      event = %{context.valid_event | version: "1.1"}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected version with 3 dots, but received 1.1"}
    end

    test "returns error when version major is not an integer", context do
      event = %{context.valid_event | version: "1a.1.1"}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a number for the major, but received 1a.1.1"}
    end

    test "returns error when version minor is not an integer", context do
      event = %{context.valid_event | version: "1.1a.1"}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a number for the minor, but received 1.1a.1"}
    end

    test "returns error when version fix is not an integer", context do
      event = %{context.valid_event | version: "1.1.1a"}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a number for the fix, but received 1.1.1a"}
    end

    test "returns error when name is not a string", context do
      event = %{context.valid_event | name: :EVENT}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a string as event name, got :EVENT"}
    end

    test "returns error when they payload is not a map", context do
      Enum.map([[], false, nil, 3, 0, "string", 'binary', :atom], fn value ->
        event = %{context.valid_event | payload: value}

        assert Event.publish(event, FakeAdapterSuccess) ==
                 {:error, "Expected payload to be a map"}
      end)
    end

    test "returns error when event_id_seed is not a UUID string", context do
      event = %{context.valid_event | event_id_seed: "not uuid string"}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a UUID string as event_id_seed, but got \"not uuid string\""}
    end

    test "returns error when event_id_seed_optional is not a string", context do
      event = %{context.valid_event | event_id_seed_optional: 123}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a string as event_id_seed_optional, but got 123"}
    end

    test "returns ok when event_id_seed_optional is string", context do
      event = %{context.valid_event | event_id_seed_optional: "i am string"}

      assert Event.publish(event, FakeAdapterSuccess) == :ok
    end

    test "returns error when occurred_at is not a datetime", context do
      event = %{context.valid_event | occurred_at: "not a datetime"}

      assert Event.publish(event, FakeAdapterSuccess) ==
               {:error, "Expected a DateTime as occurred_at, but got \"not a datetime\""}
    end

    test "returns ok when occurred_at is datetime", context do
      event = %{context.valid_event | occurred_at: Timex.now()}

      assert Event.publish(event, FakeAdapterSuccess) == :ok
    end
  end
end
