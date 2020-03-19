defmodule Support.TestRepo do
  import Ecto.Changeset, only: [apply_changes: 1]

  alias Support.TestSchema

  @spec insert(any) :: {:ok, any}
  def insert(changeset), do: {:ok, apply_changes(changeset)}

  @spec insert!(any) :: any
  def insert!(changeset), do: apply_changes(changeset)

  @spec update(any) :: {:ok, any}
  def update(changeset), do: {:ok, apply_changes(changeset)}
  @spec update!(any) :: any
  def update!(changeset), do: apply_changes(changeset)

  @spec get(any, String.t()) :: TestSchema.t() | nil
  def get(_, "existing" = id), do: %TestSchema{id: id}
  def get(_, "non-existing"), do: nil

  @spec get!(any, String.t()) :: TestSchema.t() | no_return()
  def get!(_, "existing" = id), do: %TestSchema{id: id}
  def get!(_, "non-existing" = id), do: raise(Ecto.NoResultsError, queryable: id)

  @spec get_by!(any, Keyword.t()) :: TestSchema.t() | no_return()
  def get_by!(_, id: "existing" = id), do: %TestSchema{id: id}
  def get_by!(_, id: "non-existing" = id), do: raise(Ecto.NoResultsError, queryable: id)

  @spec one(any) :: Support.TestSchema.t()
  def one(_), do: %TestSchema{id: "existing"}

  @spec all(any) :: [TestSchema.t()]
  def all(queryable \\ [])
  def all(test_field_1: "dummy"), do: [%TestSchema{test_field_1: "dummy"}]
  def all(_), do: [%TestSchema{}, %TestSchema{}]
end
