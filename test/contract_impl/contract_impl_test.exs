defmodule ElixirTools.ContractImplTest do
  use ExUnit.Case

  defmodule RealModule do
    @spec without_args :: :ok
    def without_args, do: :ok

    @spec with_args(String.t(), pos_integer) :: {:ok, String.t()}
    def with_args(string, _), do: {:ok, string}
  end

  defmodule FakeModule do
    use ElixirTools.ContractImpl, module:  ElixirTools.ContractImplTest.RealModule

    @impl true
    def with_args(_, _), do: {:ok, "waa"}
  end

  test "something" do
    assert FakeModule.with_args("string", 1) == {:ok, "waa"}
  end

  test "raises if trying to access module that doesn't exist" do
   assert RealModule.without_args == :ok
   assert_raise UndefinedFunctionError, fn -> FakeModule.without_args end
  end
end
