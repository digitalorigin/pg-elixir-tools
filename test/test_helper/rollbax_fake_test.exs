defmodule ElixirTools.RollbaxFakeTest do
  use ExUnit.Case

  alias ElixirTools.RollbaxFake

  describe "report_message/4" do
    test "sends expected message to the inbox" do
      custom = %{map: :with_value}
      occurence_data = %{map: :with_occurence_data}
      RollbaxFake.report_message(:info, "message", custom, occurence_data)

      assert_received([:rollbax_message, :info, "message", ^custom, ^occurence_data])
    end

    test "when the occurence or custom data contains a struct" do
      struct = DateTime.utc_now()

      message =
        "Rollbax does not know how to handle structs and will raise an error. Convert it to a map."

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report_message(:info, "message", struct, %{})
      end)

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report_message(:info, "message", %{}, struct)
      end)
    end

    test "when the occurence or custom data contains a nested struct" do
      struct = DateTime.utc_now()
      nested_struct = %{map: :with_value, other_value: %{with_nested: %{struct: %{dt: struct}}}}

      message =
        "Rollbax does not know how to handle structs and will raise an error. Convert it to a map."

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report_message(:info, "message", nested_struct, %{})
      end)

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report_message(:info, "message", %{}, nested_struct)
      end)
    end
  end

  describe "report/5" do
    test "sends expected message to the inbox" do
      custom = %{map: :with_value}
      occurence_data = %{map: :with_occurence_data}
      RollbaxFake.report(:info, "message", [], custom, occurence_data)

      assert_received([:rollbax_report, :info, "message", [], ^custom, ^occurence_data])
    end

    test "when the occurence or custom data contains a struct" do
      struct = DateTime.utc_now()

      message =
        "Rollbax does not know how to handle structs and will raise an error. Convert it to a map."

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report(:info, [], "message", struct, %{})
      end)

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report(:info, [], "message", %{}, struct)
      end)
    end

    test "when the occurence or custom data contains a nested struct" do
      struct = DateTime.utc_now()
      nested_struct = %{map: :with_value, other_value: %{with_nested: %{struct: %{dt: struct}}}}

      message =
        "Rollbax does not know how to handle structs and will raise an error. Convert it to a map."

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report(:info, [], "message", nested_struct, %{})
      end)

      assert_raise(RuntimeError, message, fn ->
        RollbaxFake.report(:info, [], "message", %{}, nested_struct)
      end)
    end
  end
end
