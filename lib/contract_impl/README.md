# Contract Impl

This support module helps with implementing contracts in tests. It ensures that the signature of
a method is right. This is done by creating dynamically a contract for all public functions.

To use this helper, add to the contract of the module that you want to implement:

```elixir
use ElixirTools.ContractImpl, module: PgPayments.TestModule
```

Then, all mocked methods must be using `@impl true`.

```elixir
@override true
def my_method, do: :something
```

There is a caveat. At this moment, the specs themselves are not tested, as test files are exs
files thus not dialyzed.

## Example

```elixir
use ElixirTools.ContractImpl, module: PgPayments.TestModule

@override true
def my_method, do: :something
```
