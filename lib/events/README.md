# Events

The Events section of this library is responsible of handling events in the pagantis infrastructure. It provides an adapter to work with AWS SNS, but it can work with anything.

Besides publishing this package verifies structure and definitions according to the internal packages.

## Config

The next env vars need to be set to work with AWS and this library:

```bash
AWS_ACCESS_KEY_ID=foo
AWS_SECRET_ACCESS_KEY=bar
AWS_SNS_TOPIC="arn:aws:sns:us-west-2:123456789012:topic2"
AWS_DEFAULT_REGION="us-east-1"
```

To use, add to your `config.ex`:

```elixir
config :pagantis_elixir_tools, ElixirTools.Events,
  adapter: ElixirTools.Events.Adapters.AwsSns,
  adapter_config: %{
    group: "MY_GROUP",
    topic: System.get_env("AWS_SNS_TOPIC"),
    default_region: System.get_env("AWS_DEFAULT_REGION")
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

## Usage
```elixir
Event.publish(%Event{name: "NAME_EXAMPLE", event_id_seed: "f367d382-6452-435c-ad83-3477bd530349", payload: %{key: "value"}, version: "1.0.0"}
```
Where:
* `name` - obligatory, string, contains at least one `_`
* `event_id_seed` - obligatory, string in UUID format, which will be used together with `name` as a seed for event_id generation. If both values will be the same - event will be updated in datalake.
* `payload` - optional, map
* `version` - optional, string, `\d+.\d+.\d+` format

An example can be found here [https://github.com/digitalorigin/pg-elixir-tools/tree/master/examples/events](https://github.com/digitalorigin/pg-elixir-tools/tree/master/examples/events).
