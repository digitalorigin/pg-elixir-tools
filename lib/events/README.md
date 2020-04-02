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

Add
```elixir
supervisor(Task.Supervisor, [[name: ElixirTools.TaskSupervisor]])
```
to your `application.ex`. It's needed to be able to sent event async.

Events which are failed to sent(wrong config, infrastructure issues etc.) will be save to `not_sent_events` table. 
To create this table
```bash
mix ecto.gen.migration create_not_sent_events
```

and add the following to the migration file inside the `change` function
```elixir
create table(:not_sent_events, primary_key: false) do
  add(:id, :uuid, primary_key: true)
  add(:content, :text)
  add(:is_sent, :boolean, default: false)
  timestamps()
end
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
EventHandler.create(name, payload, event_id_seed, [{:event_id_seed_optional, event_id_seed_optional}, {:occurred_at, occurred_at}, {:version, version}])
Event.publish(%Event{name: "NAME_EXAMPLE", event_id_seed: "f367d382-6452-435c-ad83-3477bd530349", payload: %{key: "value"}, version: "1.0.0"}
Event.publish(%Event{name: "NAME_EXAMPLE", event_id_seed: "f367d382-6452-435c-ad83-3477bd530349", payload: %{key: "value"}, event_json_schema, version: "1.0.0"}
```
Where:
* `name` - obligatory, string, contains at least one `_`
* `payload` - optional, map
* `event_id_seed` - obligatory, string in UUID format, which will be used together with `name`, `version` & `event_id_seed_optional` as a seed for event_id generation. 
If all values will be the same -> event_id will be the same -> event will be updated in S3.
* `event_id_seed_optional` - string, optional part used for event_id generation. By default - ""(empty string)
* `occurred_at` - optional, datetime, if provided - overwrite `current datetime` sent by default
* `version` - optional, string, overwrite default "1.0.0" value
* `event_json_schema` - JSON schema to validate event. In order to generate a JSON schema, use, for example, https://jsonschema.net/home service and provide an example of an event. This service will generate a JSON schema. Save it to a file and load it this way:

```elixir
schema = "test/events/fixtures/json_schemas/json_schema.json" |> File.read!() |> Jason.decode!()
```
and provide that loaded schema to the publish function along with the event.


An example can be found here [https://github.com/digitalorigin/pg-elixir-tools/tree/master/examples/events](https://github.com/digitalorigin/pg-elixir-tools/tree/master/examples/events).

In case if event was not sent:
* new row will be added to `not_sent_events` table
* telemetry metric will be emitted with the following data `[:pagantis_elixir_tools, :events, :not_sent], %{error_info: error_info}`. So you can attach to it with Rollbar/Logger