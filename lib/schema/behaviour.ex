defmodule ElixirTools.Schema.Behaviour do
  # Required methods in schemas
  @callback changeset(map) :: Ecto.Changeset.t()

  # Overridable methods
  @callback repo() :: any
  @callback create(any) :: any
  @callback create!(any) :: any | no_return()
  @callback insert(any) :: any
  @callback insert!(any) :: any | no_return()
  @callback validate(any) :: any
  @callback new(any) :: any
  @callback get(any) :: any
  @callback get!(any) :: any | no_return()
  @callback get_by(any) :: any
  @callback get_by!(any) :: any | no_return()
  @callback all(any) :: any
  @callback preload(any, any) :: any
  @callback update(any, any) :: any
  @callback update!(any, any) :: any | no_return()
end
