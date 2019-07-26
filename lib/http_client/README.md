# HTTP Client

The HTTP Client is responsible for doing request to the outside world and works with adapters that
are to be written by the application.

## Configuration

Setup a default config in your application:

```elixir
config :pagantis_elixir_tools, PgIssuing.Http.Client,
  response_timeout: "1000" # required
  http_client: HTTPoison # optional, default: HTTPoison
```
