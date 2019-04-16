defmodule ElixirTools.Schema.TestSchema do
  @moduledoc false
  use ElixirTools.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @type t :: %TestSchema{
          test_field_1: String.t(),
          test_field_2: String.t() | nil,
          test_field_3: String.t() | nil
        }

  repo ElixirTools.Schema.TestRepo

  @allowed_fields ~w(test_field_1 test_field_2 test_field_3)a
  @required_fields [:test_field_1]

  schema "test_schema" do
    field(:test_field_1, :string)
    field(:test_field_2, :string)
    field(:test_field_3, :string, default: "new")
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params \\ %{}) do
    %TestSchema{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
  end
end
