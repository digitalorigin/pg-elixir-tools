# Metrix

Metrix is the logic we use to send statics.

Metrix works with adapters and comes with 3 adapters by default:

[IgnoreAdapter](lib/metrix/adapters/ignore.ex): Ignores all incoming requests. Ideal for development
[LogAdapter](lib/metrix/adapters/log.ex): Logs all metrics. Ideal for testing and development.
[StatixAdapter](lib/metrix/adapters/statix.ex): Sends the metrics to a backend.

It comes with erlang statistics out of the box. This needs to be enabled in the configuration.
Metrix also provides a [plug](lib/metrix/plug.ex) that measures the times of controllers.

## Configuration

In the supervision tree of your `application.ex`, add in the `children` section:

```elixir
      ElixirTools.Metrix.Supervisor
```

For Phoenix, add the [plug](lib/metrix/plug.ex) in the `router.ex` so requests are measured:

```elixir
    plug(ElixirTools.Metrix.Plug)
```

Now configure your metrix using the config:

config.exs

```elixir
config :pagantis_elixir_tools, ElixirTools.Metrix,
  default_tags: %{
    code_version: System.get_env("CODE_VERSION") || "not-versioned",
    environment: System.get_env("STATSD_ENV") || "dev",
    hostname: hostname
  },
  adapter: ElixirTools.Metrix.Adapters.Log,
  recurrent_metrics: [
    {ElixirTools.Metrix.Recurring.ErlangStats, []}
  ]
```

dev.exs

```elixir
config :pg_issuing, Metrix, adapter: Metrix.Adapters.Log
```

test.exs

```elixir
config :pagantis_elixir_tools, ElixirTools.Metrix, default_tags: %{default_tag: "1", other_default_tag: "2"}
```

prod.exs
The Statix adapter needs specific configuration to configure the statix library.


```elixir
config :pagantis_elixir_tools, ElixirTools.Metrix, adapter: Metrix.Adapters.Statix

config :statix,
  prefix: "my.application",
  host: System.get_env("STATSD_HOST") || "127.0.0.1",
  port: String.to_integer(System.get_env("STATSD_PORT") || "8125")
```
