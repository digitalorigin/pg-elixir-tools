defmodule Support.UniqueConstraintTestSchema do
  @moduledoc false
  use ElixirTools.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @type t :: %UniqueConstraintTestSchema{}

  @impl true
  def repo, do: Support.UniqueConstraintTestRepo

  @allowed_fields ~w(test_field_1 test_field_2)a
  @required_fields [:test_field_1]

  schema "test_schema" do
    field(:test_field_1, :string)
    field(:test_field_2, :string)
  end

  @impl true
  def changeset(params \\ %{}) do
    %UniqueConstraintTestSchema{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.unique_constraint(:test_field_2)
  end
end
