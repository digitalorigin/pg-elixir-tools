# Events

The Events section of this library is responsible of handling events in the pagantis infrastructure. It provides an adapter to work with AWS SNS, but it can work with anything.

Besides publishing this package verifies structure and definitions according to the internal packages. An [implementation](examples/events/charge.ex) has been added as example.

## Config

The next env vars need to be set to work with AWS and this library

```bash
AWS_ACCESS_KEY_ID=foo
AWS_SECRET_ACCESS_KEY=bar
AWS_SNS_TOPIC="arn:aws:sns:us-west-2:123456789012:topic2"
```

To use, add to your `config.ex`:

```elixir
config :pagantis_elixir_tools, ElixirTools.Events,
  adapter: ElixirTools.Events.Adapters.AwsSns,
  adapter_config: %{
    group: "MY_GROUP",
    topic: System.get_env("AWS_SNS_TOPIC")
  }
```

For local development with localstack, also add:

```elixir
config :ex_aws, :sns,
  scheme: "http://",
  host: "localhost",
  port: 4575,
  region: "us-west-2"
```
