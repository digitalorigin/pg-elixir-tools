defmodule ElixirTools.Schema.TestRepo do
  alias ElixirTools.TestSchema
  import Ecto.Changeset, only: [apply_changes: 1]

  def insert(record), do: {:ok, record}
  def insert!(record), do: record

  def update(changeset), do: {:ok, apply_changes(changeset)}
  def update!(changeset), do: apply_changes(changeset)

  def get(_, "existing" = id), do: %TestSchema{id: id}
  def get(_, "non-existing"), do: nil

  def get!(_, "existing" = id), do: %TestSchema{id: id}
  def get!(_, "non-existing" = id), do: raise(Ecto.NoResultsError, queryable: id)

  def get_by!(_, id: "existing" = id), do: %TestSchema{id: id}
  def get_by!(_, id: "non-existing" = id), do: raise(Ecto.NoResultsError, queryable: id)
end
