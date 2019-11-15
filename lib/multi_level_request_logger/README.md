# Multi level request logger

The Multi level request logger allows defining different log levels for different requests.

## Usage

Replace in your project, usually in the `endpoint.ex`:

```elixir
  plug(Plug.Logger)
```

with

```elixir
  plug(ElixirTools.MultiLevelRequestLogger.Plug)
```

Then, specify in your configuration the specific log levels:

```elixir
config :pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger,
  default_log_level: :info,
  path_log_level: %{
    "/status/elb_ping" => :debug,
    "..." => :error
  }
```
