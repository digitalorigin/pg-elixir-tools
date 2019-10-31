defmodule ElixirTools.TestHelper.DateTimeFakeTest do
  use ExUnit.Case, async: true

  alias ElixirTools.TestHelper.DateTimeFake

  describe "utc_now/0" do
    test "returns expected value and sends expected message" do
      assert DateTimeFake.utc_now() == "2019-05-02 13:59:45.103716Z"
      assert_received :utc_now
    end
  end

  describe "to_string/1" do
    test "returns expected value and sends expected message" do
      assert DateTimeFake.to_string("datetime") == "2019-05-02 13:59:45.103716Z"
      assert_received {:date_time_to_string, "datetime"}
    end
  end

  describe "get_datetime/0" do
    test "returns expected value" do
      assert DateTimeFake.get_datetime() == ~U[2019-05-02 13:59:45.103716Z]
    end
  end
end
