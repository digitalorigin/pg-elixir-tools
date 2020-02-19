# IdempotencyKey
## Description
Provides functionality for idempotent controllers. Extract, verify format of idempotency keys.

## Usage
Most like you want to add it your contoller. An example of usage:

```elixir
  def create(conn, params) do
    with    {:ok, idempotency_key} <- IdempotencyKey.get(conn),
            {:ok, schema} <- validate_params_and_add_idempotency_key(params, idempotency_key),
            {:ok, entity} <- create_entity(schema) do
    else
      {:error, :wrong_format_idempotency_key} -> bad_input(conn, "Idempotency key should be UUID")
      error -> error
    end
```
Or handle `{:error, :wrong_format_idempotency_key}` in your `FallbackController`