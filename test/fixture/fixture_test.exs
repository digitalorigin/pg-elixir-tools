defmodule ElixirTools.FixtureTest do
  use ExUnit.Case

  alias ElixirTools.Fixture

  describe "load_json!/1" do
    test "when the file exist, it returns the content of the file as object" do
      res = Fixture.load_json!("fixture/valid_json")
      assert res == %{"a" => "test", "b" => 2, "c" => true}
    end

    test "when the file does not exist, it throws an error" do
      expected_message =
        "could not read file \"test/fixtures/non_existing.json\": no such file or directory"

      assert_raise File.Error, expected_message, fn -> Fixture.load_json!("non_existing") end
    end
  end

  describe "load!/1" do
    test "when the file exist, it returns the content of the file as text" do
      res = Fixture.load!("fixture/valid_json")
      assert res == "{\n  \"a\": \"test\",\n  \"b\": 2,\n  \"c\": true\n}\n"
    end

    test "when the file does not exist, it throws an error" do
      expected_message =
        "could not read file \"test/fixtures/non_existing.json\": no such file or directory"

      assert_raise File.Error, expected_message, fn -> Fixture.load!("non_existing") end
    end
  end
end
