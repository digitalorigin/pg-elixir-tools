defmodule ElixirTools.SchemaTest do
  use ExUnit.Case, async: true
  alias ElixirTools.Schema
  alias Support.{TestSchema, UniqueConstraintTestSchema}

  describe "repo/1" do
    test "returns default" do
      assert Schema.default_repo() == Support.TestRepo
    end

    test "can be overriden" do
      assert TestSchema.repo() == Support.TestRepo
    end
  end

  describe "new/1" do
    test "returns a struct with the correct values" do
      input = %{test_field_1: "1", test_field_2: "2", test_field_3: "3"}
      result = TestSchema.new(input)

      expected = %TestSchema{
        test_field_1: "1",
        test_field_2: "2",
        test_field_3: "3"
      }

      assert result == expected
    end

    test "only casts valid values" do
      input = %{test_field_1: 123, test_field_2: :foo, test_field_3: "string"}
      result = TestSchema.new(input)

      expected = %TestSchema{
        test_field_1: nil,
        test_field_2: nil,
        test_field_3: "string"
      }

      assert result == expected
    end

    test "returns default values" do
      input = %{}
      result = TestSchema.new(input)

      expected = %TestSchema{
        test_field_1: nil,
        test_field_2: nil,
        test_field_3: "new"
      }

      assert result == expected
    end
  end

  describe "validate/1" do
    test "returns :ok when tuple is valid" do
      valid_input = %{
        test_field_1: "1",
        test_field_2: "2",
        test_field_3: "3"
      }

      assert {:ok, changeset} = TestSchema.validate(valid_input)
      assert changeset.changes == valid_input
    end

    test "returns error tuple when invalid" do
      valid_input = %{
        test_field_1: "1",
        test_field_2: :invalid,
        test_field_3: "3"
      }

      expected = {:error, [test_field_2: {"is invalid", [type: :string, validation: :cast]}]}
      assert TestSchema.validate(valid_input) == expected
    end

    test "validates only required values" do
      valid_input = %{test_field_2: "2"}
      expected = {:error, [test_field_1: {"can't be blank", [validation: :required]}]}
      assert TestSchema.validate(valid_input) == expected
    end
  end

  describe "insert/1" do
    test "does not allow the insertion of maps" do
      map = %{}

      assert_raise(FunctionClauseError, fn ->
        TestSchema.insert(map)
      end)
    end

    test "validates before insert" do
      invalid_schema = %TestSchema{}
      expected = {:error, [test_field_1: {"can't be blank", [validation: :required]}]}
      assert TestSchema.insert(invalid_schema) == expected
    end

    test "does the insert if the schema is valid" do
      schema = %TestSchema{test_field_1: "1", test_field_2: "2", test_field_3: "3"}
      assert TestSchema.insert(schema) == {:ok, schema}
    end

    test "returns an error tuple if there's a unique constraint error" do
      schema = %UniqueConstraintTestSchema{test_field_1: "one", test_field_2: "two"}

      expected_errors = [
        test_field_2:
          {"has already been taken",
           [constraint: :unique, constraint_name: "dummy_table_test_field_2_index"]}
      ]

      assert {:error, %{errors: ^expected_errors}} = UniqueConstraintTestSchema.insert(schema)
    end
  end

  describe "insert!/1" do
    test "does not allow the insertion of maps" do
      map = %{}

      assert_raise(FunctionClauseError, fn ->
        TestSchema.insert!(map)
      end)
    end

    test "validates before insert" do
      invalid_schema = %TestSchema{}

      assert_raise(RuntimeError, fn ->
        TestSchema.insert!(invalid_schema)
      end)
    end

    test "does the insert if the schema is valid" do
      schema = %TestSchema{test_field_1: "1", test_field_2: "2", test_field_3: "3"}
      assert TestSchema.insert!(schema) == schema
    end

    test "raises an error if there's a unique constraint error" do
      schema = %UniqueConstraintTestSchema{test_field_1: "one", test_field_2: "two"}

      assert_raise(RuntimeError, "test_field_2 unique constraint error", fn ->
        UniqueConstraintTestSchema.insert!(schema)
      end)
    end
  end

  describe "update/2" do
    test "validates before update" do
      invalid_schema = %TestSchema{}
      expected = {:error, [test_field_1: {"can't be blank", [validation: :required]}]}
      assert TestSchema.update(invalid_schema, %{}) == expected
    end

    test "does the update if the schema is valid" do
      schema = %TestSchema{test_field_1: "1", test_field_2: "2", test_field_3: "3"}
      assert TestSchema.insert!(schema) == schema
      changes = %{test_field_2: "4"}
      assert {:ok, schema} = TestSchema.update(schema, changes)
      assert schema.test_field_2 == "4"
    end

    test "does not update the fields which are not in the module schema's `@allowed_fields`" do
      schema = %TestSchema{test_field_1: "one"}
      assert TestSchema.insert!(schema) == schema
      changes = %{test_field_4: "updated!"}

      # No values should be updated
      assert TestSchema.update(schema, changes) == {:ok, schema}
    end
  end

  describe "update!/2" do
    test "validates before update" do
      invalid_schema = %TestSchema{}

      assert_raise(RuntimeError, fn ->
        TestSchema.update!(invalid_schema, %{})
      end)
    end

    test "does the update if the schema is valid" do
      schema = %TestSchema{test_field_1: "1", test_field_2: "2", test_field_3: "3"}
      assert TestSchema.insert!(schema) == schema
      changes = %{test_field_2: "4"}
      assert schema = TestSchema.update!(schema, changes)
      assert schema.test_field_2 == "4"
    end

    test "does not update the fields which are not in the module schema's `@allowed_fields`" do
      schema = %TestSchema{test_field_1: "one"}
      assert TestSchema.insert!(schema) == schema
      changes = %{test_field_4: "updated!"}

      # No values should be updated
      assert TestSchema.update!(schema, changes) == schema
    end
  end

  describe "get/1" do
    test "returns a struct when it can be found" do
      assert TestSchema.get("existing") == %TestSchema{
               id: "existing",
               test_field_1: nil,
               test_field_2: nil,
               test_field_3: "new"
             }
    end

    test "returns nil when it cannot be found" do
      assert TestSchema.get("non-existing") == nil
    end
  end

  describe "get!/1" do
    test "returns a struct when it can be found" do
      assert TestSchema.get!("existing") == %TestSchema{
               id: "existing",
               test_field_1: nil,
               test_field_2: nil,
               test_field_3: "new"
             }
    end

    test "raises Ecto.NoResultsError if nothing was found" do
      assert_raise(Ecto.NoResultsError, fn ->
        TestSchema.get!("non-existing")
      end)
    end
  end

  describe "get_by!/1" do
    test "returns a struct when it can be found by key" do
      assert TestSchema.get_by!(id: "existing") == %TestSchema{
               id: "existing",
               test_field_1: nil,
               test_field_2: nil,
               test_field_3: "new"
             }
    end

    test "raises Ecto.NoResultsError if nothing was found by key" do
      assert_raise(Ecto.NoResultsError, fn ->
        TestSchema.get_by!(id: "non-existing")
      end)
    end
  end

  describe "create/1" do
    test "validates before insertion" do
      map = %{}
      expected = {:error, [test_field_1: {"can't be blank", [validation: :required]}]}
      assert TestSchema.create(map) == expected
    end

    test "inserts the value if it is a valid map" do
      map = %{test_field_1: "1", test_field_2: "2", test_field_3: "3"}

      expected =
        {:ok,
         %Support.TestSchema{
           id: nil,
           test_field_1: "1",
           test_field_2: "2",
           test_field_3: "3"
         }}

      assert TestSchema.create(map) == expected
    end
  end

  describe "create!/1" do
    test "validates before insertion and raises if fails" do
      invalid_map = %{}

      assert_raise(RuntimeError, fn ->
        TestSchema.create!(invalid_map)
      end)
    end

    test "inserts the value if it is a valid map" do
      map = %{test_field_1: "1", test_field_2: "2", test_field_3: "3"}

      expected = %Support.TestSchema{
        id: nil,
        test_field_1: "1",
        test_field_2: "2",
        test_field_3: "3"
      }

      assert TestSchema.create!(map) == expected
    end
  end

  describe "repo/0" do
    test "returns the repo" do
      assert TestSchema.repo() == Support.TestRepo
    end
  end

  describe "all/0" do
    test "returns a list of records if they are stored in the db" do
      assert TestSchema.all() == [%TestSchema{}, %TestSchema{}]
    end
  end

  describe "all/1" do
    test "returns a list of records based on the query" do
      assert TestSchema.all(test_field_1: "dummy") == [%TestSchema{test_field_1: "dummy"}]
    end
  end
end
