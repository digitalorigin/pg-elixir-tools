defmodule ElixirTools.Schema do
  @moduledoc false

  alias Ecto.Changeset

  @type id :: Ecto.UUID.t()

  # Required methods in schemas
  @callback changeset(map) :: Changeset.t()

  # Overridable methods
  @callback repo() :: any
  @callback create(any) :: any
  @callback create!(any) :: any
  @callback insert(any) :: any
  @callback insert!(any) :: any
  @callback validate(any) :: any
  @callback new(any) :: any
  @callback get(any) :: any
  @callback get!(any) :: any
  @callback get_by(any) :: any
  @callback get_by!(any) :: any
  @callback update!(any, any) :: any
  @callback preload(any, any) :: any

  @default_repo Application.get_env(:pagantis_elixir_tools, :schema)[:default_repo]
  def default_repo, do: @default_repo

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      @timestamps_opts [type: :utc_datetime_usec]

      import Ecto.Query
      import ElixirTools.Schema

      alias Ecto.Changeset
      alias ElixirTools.Schema

      @behaviour ElixirTools.Schema

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
      def create(map \\ %{}) do
        map |> new() |> insert()
      end

      @doc """
      The same as create/1 but raises an error when validation fails.
      """
      @spec create!(map) :: t | no_return()
      def create!(map \\ %{}) do
        map |> new() |> insert!()
      end

      @doc """
      Alters the struct with the values and updates the database record.
      The first argument takes the original struct, the second a map with changes.
      """
      @spec update(struct, map) :: {:ok, t} | {:error, [{}]}
      def update(%{__struct__: _} = struct, map) do
        changeset = Changeset.change(struct, map)
        updated_struct = Changeset.apply_changes(changeset)

        with :ok <- validate(updated_struct) do
          repo().update(changeset)
        end
      end

      @doc """
      The same as `update/2` but raises an error when validation fails.
      """
      @spec update!(struct, map) :: t | no_return()
      def update!(%{__struct__: _} = struct, map) do
        changeset = Changeset.change(struct, map)
        updated_struct = Changeset.apply_changes(changeset)

        case validate(updated_struct) do
          :ok -> repo().update!(changeset)
          error -> raise inspect(error)
        end
      end

      @doc """
      Inserts a struct into the database.
      """
      @spec insert(t) :: {:ok, t} | {:error, term}
      def insert(%{__struct__: _} = struct) do
        with :ok <- validate(struct) do
          repo().insert(struct)
        end
      end

      @doc """
      Inserts a struct in the database and throws an error when it fails.
      """
      @spec insert!(t) :: t | no_return()
      def insert!(%{__struct__: _} = struct) do
        case validate(struct) do
          :ok -> repo().insert!(struct)
          error -> raise inspect(error)
        end
      end

      @doc """
      Creates a new changeset by providing `map`. Returns a struct of the type with the defaults
      set. Keep in mind that `new/1` does not validate.
      """
      @spec new(map) :: t
      def new(map \\ %{}) do
        changeset = changeset(map)
        Changeset.apply_changes(changeset)
      end

      @doc """
      Validates a map or struct.
      """
      @spec validate(map | t) :: :ok | {:error, [{}]}
      def validate(%{__struct__: _} = struct), do: struct |> Map.from_struct() |> validate

      def validate(map) do
        changeset = changeset(map)

        if changeset.valid? do
          :ok
        else
          {:error, changeset.errors}
        end
      end

      @doc """
      Gets a struct from the database by providing the ID
      """
      @spec get(Schema.id()) :: t | nil
      def get(id), do: repo().get(__MODULE__, id)

      @doc """
      Gets a struct from the database by providing the ID, raises Ecto.NoResultsError if no record was found
      """
      @spec get!(Schema.id()) :: t | no_return()
      def get!(id), do: repo().get!(__MODULE__, id)

      @doc """
      Gets the first record by `key`: `value`
      """
      @spec get_by(list) :: t | nil
      def get_by(queryable), do: repo().get_by(__MODULE__, queryable)

      @doc """
      Gets the first record by `key`: `value`
      """
      @spec get_by!(list) :: t | no_return
      def get_by!(queryable), do: repo().get_by!(__MODULE__, queryable)

      @doc """
      Preloads a field on a struct.
      """
      @spec preload(t, field :: atom | [atom]) :: t
      def preload(struct, field, opts \\ []), do: repo().preload(struct, field, opts)

      defoverridable ElixirTools.Schema
    end
  end

  defmacro repo(repo) do
    quote do
      @doc """
      Returns the repo for the current schema
      """
      def repo(), do: unquote(repo)
    end
  end
end
