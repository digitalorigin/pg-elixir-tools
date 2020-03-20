defmodule ElixirTools.Schema.SchemaImpl do
  alias Ecto.Changeset
  alias ElixirTools.Schema

  import Ecto.Query, only: [from: 2]

  @typep repo :: module
  @typep ecto_schema :: module
  @type t :: struct

  @doc """
  Creates a new __MODULE__ struct by parameters and inserts it in the database when the values
  are valid
  """
  @spec create(ecto_schema, map) :: {:ok, t} | {:error, [{}]}
  def create(module, map \\ %{}) do
    insert(module, new(module, map))
  end

  @doc """
  The same as create/1 but raises an error when validation fails.
  """
  @spec create!(ecto_schema, map) :: t | no_return()
  def create!(module, map \\ %{}), do: insert!(module, new(module, map))

  @doc """
  Alters the struct with the values and updates the database record.
  The first argument takes the original struct, the second a map with changes.
  """
  @spec update(ecto_schema, struct, map) :: {:ok, t} | {:error, [{}]}
  def update(module, %{__struct__: _} = struct, map) do
    # "Filter" the map values to only include the module changeset's `@allowed_fields`
    map = module.changeset(map).changes
    changeset = Changeset.change(struct, map)
    updated_struct = Changeset.apply_changes(changeset)

    with {:ok, changeset} <- validate(module, updated_struct) do
      module.repo().update(%Changeset{changeset | data: updated_struct})
    end
  end

  @doc """
  The same as `update/2` but raises an error when validation fails.
  """
  @spec update!(ecto_schema, struct, map) :: t | no_return()
  def update!(module, %{__struct__: _} = struct, map) do
    map = module.changeset(map).changes
    changeset = Changeset.change(struct, map)
    updated_struct = Changeset.apply_changes(changeset)

    case validate(module, updated_struct) do
      {:ok, changeset} -> module.repo().update!(%Changeset{changeset | data: updated_struct})
      error -> raise inspect(error)
    end
  end

  @doc """
  Inserts a struct into the database.
  """
  @spec insert(ecto_schema, t) :: {:ok, t} | {:error, term}
  def insert(module, %{__struct__: _} = struct) do
    with {:ok, changeset} <- validate(module, struct) do
      module.repo.insert(changeset)
    end
  end

  @doc """
  Inserts a struct in the database and throws an error when it fails.
  """
  @spec insert!(ecto_schema, t) :: t | no_return()
  def insert!(module, %{__struct__: _} = struct) do
    case validate(module, struct) do
      {:ok, changeset} -> module.repo.insert!(changeset)
      error -> raise inspect(error)
    end
  end

  @doc """
  Creates a new changeset by providing `map`. Returns a struct of the type with the defaults
  set. Keep in mind that `new/1` does not validate.
  """
  @spec new(ecto_schema, map) :: t
  def new(module, map \\ %{}) do
    changeset = module.changeset(map)
    Changeset.apply_changes(changeset)
  end

  @doc """
  Validates a map or struct.
  """
  @spec validate(ecto_schema, map | t) :: {:ok, Changeset.t()} | {:error, [{}]}
  def validate(module, %{__struct__: _} = struct) do
    validate(module, Map.from_struct(struct))
  end

  def validate(module, map) do
    changeset = module.changeset(map)

    if changeset.valid? do
      {:ok, changeset}
    else
      {:error, changeset.errors}
    end
  end

  @doc """
  Gets a struct from the database by providing the ID
  """
  @spec get(ecto_schema, Schema.id()) :: t | nil
  def get(module, id), do: module.repo.get(module, id)

  @doc """
  Gets a struct from the database by providing the ID, raises Ecto.NoResultsError if no record was found
  """
  @spec get!(ecto_schema, Schema.id()) :: t | no_return()
  def get!(module, id), do: module.repo.get!(module, id)

  @doc """
  Gets the first record by `key`: `value`
  """
  @spec get_by(ecto_schema, list) :: t | nil
  def get_by(module, queryable), do: module.repo.get_by(module, queryable)

  @spec last(ecto_schema, atom, any) :: t | nil
  def last(module, field, value) do
    query =
      from(m in module,
        where: field(m, ^field) == ^value,
        order_by: [desc: m.inserted_at],
        limit: 1
      )

    module.repo.one(query)
  end

  @doc """
  Gets the first record by `key`: `value`
  """
  @spec get_by!(ecto_schema, list) :: t | no_return
  def get_by!(module, queryable), do: module.repo.get_by!(module, queryable)

  @doc """
  Gets all entities based on query. If no query is given, all entities are returned.
  """
  @spec all(ecto_schema, Ecto.Query.t() | module) :: [t]
  def all(module, queryable), do: module.repo.all(queryable)

  @doc """
  Preloads a field on a struct.
  """
  @spec preload(repo, t, field :: atom | [atom], list) :: t
  def preload(repo, struct, field, opts \\ []), do: repo.preload(struct, field, opts)
end
