defmodule Support.TestSchema do
  @moduledoc false
  use ElixirTools.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @type t :: %TestSchema{}

  @impl true
  def repo, do: Support.TestRepo

  @allowed_fields ~w(test_field_1 test_field_2 test_field_3)a
  @required_fields [:test_field_1]

  schema "test_schema" do
    field(:test_field_1, :string)
    field(:test_field_2, :string)
    field(:test_field_3, :string, default: "new")
    field(:test_field_4, :string, default: "four")
  end

  @impl true
  def changeset(params \\ %{}) do
    %TestSchema{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
  end
end
