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
      assert :ok == Event.publish(context.valid_event, FakeAdapterSuccess)
    end

    test "returns error when adapter throws error", context do
      assert {:error, %RuntimeError{message: "ERROR"}} ==
               Event.publish(context.valid_event, FakeAdapterError)
    end

    test "returns error when version is not a string", context do
      event = %{context.valid_event | version: 1}

      assert {:error, "Expected a string with a version"} ==
               Event.publish(event, FakeAdapterSuccess)
    end

    test "returns error when version is not having mayor.minor.fix format", context do
      event = %{context.valid_event | version: "1.1"}

      assert {:error, "Expected version with 3 dots, but received 1.1"} ==
               Event.publish(event, FakeAdapterSuccess)
    end

    test "returns error when version mayor is not an integer", context do
      event = %{context.valid_event | version: "1a.1.1"}

      assert {:error, "Expected a number for the mayor, but received 1a.1.1"} ==
               Event.publish(event, FakeAdapterSuccess)
    end

    test "returns error when version minor is not an integer", context do
      event = %{context.valid_event | version: "1.1a.1"}

      assert {:error, "Expected a number for the minor, but received 1.1a.1"} ==
               Event.publish(event, FakeAdapterSuccess)
    end

    test "returns error when version fix is not an integer", context do
      event = %{context.valid_event | version: "1.1.1a"}

      assert {:error, "Expected a number for the fix, but received 1.1.1a"} ==
               Event.publish(event, FakeAdapterSuccess)
    end

    test "returns error when name does not contain an underscore", context do
      event = %{context.valid_event | name: "EVENT"}

      assert {:error, "Expected an underscore in the event name, but got EVENT instead"} ==
               Event.publish(event, FakeAdapterSuccess)
    end

    test "returns error when name is not a string", context do
      event = %{context.valid_event | name: :EVENT}

      assert {:error, "Expected a string as event name, but got :EVENT"} ==
               Event.publish(event, FakeAdapterSuccess)
    end

    test "returns error when they payload is not a map", context do
      Enum.map([[], false, nil, 3, 0, "string", 'binary', :atom], fn value ->
        event = %{context.valid_event | payload: value}

        assert {:error, "Expected payload to be a map"} ==
                 Event.publish(event, FakeAdapterSuccess)
      end)
    end

    test "returns error when event_id_seed is not a UUID string", context do
      event = %{context.valid_event | event_id_seed: "not uuid string"}

      assert {:error, "Expected a UUID string as event_id_seed, but got \"not uuid string\""} ==
               Event.publish(event, FakeAdapterSuccess)
    end
  end
end
