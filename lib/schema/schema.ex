defmodule ElixirTools.Schema do
  @moduledoc """
  The `Schema` provides functionality for working simple and productive with Ecto.
  """
  alias Ecto.Changeset

  @type id :: Ecto.UUID.t()

  def default_repo do
    Application.get_env(:pagantis_elixir_tools, ElixirTools.Schema)[:default_repo]
  end

  # Required methods in schemas
  @callback changeset(map) :: Changeset.t()

  defmacro __using__(_) do
    quote do
      @behaviour ElixirTools.Schema.Behaviour

      use Ecto.Schema

      import Ecto.Query

      alias Ecto.Changeset
      alias ElixirTools.Schema

      @timestamps_opts [type: :utc_datetime_usec]
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      # define types for usage in all schemas
      @type id :: Schema.id()

      @doc """
      Returns the default repo
      """
      @spec repo :: module
      def repo, do: Schema.default_repo()

      @doc """
      Creates a new __MODULE__ struct by parameters and inserts it in the database when the values
      are valid
      """
      @spec create(map) :: {:ok, t} | {:error, [{}]}
      def create(map \\ %{}), do: Schema.SchemaImpl.create(__MODULE__, map)

      @doc """
      The same as create/1 but raises an error when validation fails.
      """
      @spec create!(map) :: t | no_return()
      def create!(map \\ %{}), do: Schema.SchemaImpl.create!(__MODULE__, map)

      @doc """
      Alters the struct with the values and updates the database record.
      The first argument takes the original struct, the second a map with changes.
      """
      @spec update(t, changes :: map) :: {:ok, t} | {:error, [{}]}
      def update(%{__struct__: _} = struct, map) do
        Schema.SchemaImpl.update(__MODULE__, struct, map)
      end

      @doc """
      The same as `update/2` but raises an error when validation fails.
      """
      @spec update!(t, changes :: map) :: t | no_return()
      def update!(%{__struct__: _} = struct, map) do
        Schema.SchemaImpl.update!(__MODULE__, struct, map)
      end

      @doc """
      Inserts a struct into the database.
      """
      @spec insert(t) :: {:ok, t} | {:error, term}
      def insert(%{__struct__: _} = struct), do: Schema.SchemaImpl.insert(__MODULE__, struct)

      @doc """
      Inserts a struct in the database and throws an error when it fails.
      """
      @spec insert!(t) :: t | no_return()
      def insert!(%{__struct__: _} = struct), do: Schema.SchemaImpl.insert!(__MODULE__, struct)

      @doc """
      Creates a new changeset by providing `map`. Returns a struct of the type with the defaults
      set. Keep in mind that `new/1` does not validate.
      """
      @spec new(map) :: t
      def new(map \\ %{}), do: Schema.SchemaImpl.new(__MODULE__, map)

      @doc """
      Validates a map or struct.
      """
      @spec validate(map | t) :: {:ok, Changeset.t()} | {:error, [{}]}
      def validate(map_or_struct), do: Schema.SchemaImpl.validate(__MODULE__, map_or_struct)

      @doc """
      Gets a struct from the database by providing the ID
      """
      @spec get(Schema.id()) :: t | nil
      def get(id), do: Schema.SchemaImpl.get(__MODULE__, id)

      @doc """
      Gets a struct from the database by providing the ID, raises Ecto.NoResultsError if no record was found
      """
      @spec get!(Schema.id()) :: t | no_return()
      def get!(id), do: Schema.SchemaImpl.get!(__MODULE__, id)

      @doc """
      Gets the first record by `key`: `value`
      """
      @spec get_by(list) :: t | nil
      def get_by(queryable), do: Schema.SchemaImpl.get_by(__MODULE__, queryable)

      @doc """
      Gets the first record by `key`: `value`
      """
      @spec get_by!(list) :: t | no_return
      def get_by!(queryable), do: Schema.SchemaImpl.get_by!(__MODULE__, queryable)

      @doc """
      Gets the last record (by inserted_at) where given field equals given value.
      Returns `nil` if nothing was found.
      """
      @spec last(any, atom) :: t | nil
      def last(value, field), do: Schema.SchemaImpl.last(__MODULE__, value, field)

      @doc """
      Fetches all records from the DB.
      """
      @spec all(list) :: [t]
      def all(queryable \\ []), do: Schema.SchemaImpl.all(__MODULE__, queryable)

      @doc """
      Preloads a field or multiple fields on a struct.
      """
      @spec preload(t, field :: atom | [atom], list) :: t
      def preload(%{__struct__: _} = struct, field, opts \\ []) do
        Schema.SchemaImpl.preload(repo(), struct, field, opts)
      end

      defoverridable ElixirTools.Schema.Behaviour
    end
  end
end
