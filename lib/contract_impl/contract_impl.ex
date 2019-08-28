defmodule ElixirTools.ContractImpl do
  @moduledoc """
  This support module helps with implementing contracts in tests. It ensures that the signature of
  a method is right. This is done by creating dynamically a contract for all public functions.

  To use this helper, add to the contract of the module that you want to implement:
  `    use ElixirTools.ContractImpl, module: MyApp.TestModule`

  Then, all mocked methods must be using `@impl true`.

  There is a caveat. At this moment, the specs themselves are not tested, as test files are exs
  files thus not dialyzable.
  """

  alias __MODULE__

  defmacro __using__(args) do
    module = ContractImpl.arg_to_module!(args[:module])
    functions = module.__info__(:functions)

    quote bind_quoted: [functions: functions, module: module] do
      defmodule Contract do
        Enum.each(functions, fn {method, arity} ->
          arguments = List.duplicate({:any, [], nil}, arity)

          @callback unquote(method)(unquote_splicing(arguments)) :: any
        end)

        @optional_callbacks functions
      end

      @behaviour Contract

      defoverridable Contract
    end
  end

  @no_module_error "There was no module specified."
  @spec arg_to_module!(any) :: module | no_return()
  def arg_to_module!({_, _, module_param}) do
    module_param
    |> Enum.reduce("Elixir", &"#{&2}.#{to_string(&1)}")
    |> String.to_atom()
  end

  def arg_to_module!(_), do: raise(@no_module_error)
end
