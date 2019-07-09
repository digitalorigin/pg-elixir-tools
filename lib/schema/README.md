# Schema
This module is designed to simplify usage of `Ecto.Repo` functions.
For example, instead of `MyRepo.get(Post, 42)` you can write just `Post.get(42)`

## Setup
Add to `config.exs`

```
config :pagantis_elixir_tools, ElixirTools.Schema, default_repo: YourDefaultRepo
```

## Usage
After this most likely you want to add to your project schemas

```elixir
  use ElixirTools.Schema
```
 After this you can use it as simple as
```elixir
  Post.create!(%{title: "My super post", creator: "Mr. Writer"})
```
