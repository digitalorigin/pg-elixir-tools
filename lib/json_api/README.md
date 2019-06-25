# JSON API

This module helps implementing Jaserializer consistently between applications.

## Setup

Add the error view to the application:

config.ex:

```elixir
config :pagantis_elixir_tools, ElixirTools.JsonApi.Controller,
  error_view: MyApplication.MyErrorView
```

Prepare the router.ex, so all requests going to /api are JSON api and validated by the plug

```elixir
  pipeline :api do
    plug(:accepts, ["json-api"])
    plug(ElixirTools.JsonApi.ValidationPlug)
  end
```

Use in all controllers the JsonApi.Controller:

```elixir
  use PgPaymentsWeb, :controller
  use ElixirTools.JsonApi.Controller
```

and in all views the JsonApi.View:

```elixir
  use PgIssuingWeb, :view
  use ElixirTools.JsonApi.View
```
