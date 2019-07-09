defmodule Support.UniqueConstraintTestRepo do
  alias Ecto.Changeset

  @spec insert(any) :: {:error, Changeset.t()}
  def insert(_), do: fail()

  @spec insert!(any) :: no_return()
  def insert!(_), do: fail!()

  @spec update(any, any) :: {:error, Changeset.t()}
  def update(_, _), do: fail()

  @spec update!(any, any) :: no_return()
  def update!(_, _), do: fail!()

  @spec fail() :: {:error, Changeset.t()}
  defp fail() do
    {:error,
     %Changeset{
       errors: [
         test_field_2:
           {"has already been taken",
            [constraint: :unique, constraint_name: "dummy_table_test_field_2_index"]}
       ]
     }}
  end

  @spec fail!() :: no_return()
  defp fail!() do
    raise "test_field_2 unique constraint error"
  end
end
