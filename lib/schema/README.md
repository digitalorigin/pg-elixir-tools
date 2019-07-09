# Schema
This module is designed to simplify usage of `Ecto.Repo` functions.

## Setup
Add to `config.exs`

```
config :pagantis_elixir_tools, ElixirTools.Schema, default_repo: YourDefaultRepo
```

## Usage
After this most likely you want to add 

```elixir
  use PgPayments.Schema
```
to your project schemas. After this you can use it as simple as
```elixir
  YourSchema.create!(%{field1: value1, field2: value2})
```
