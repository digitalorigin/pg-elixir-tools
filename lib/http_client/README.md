# HTTP Client

The HTTP Client is responsible for doing request to the outside world and works with adapters that
are to be written by the application.

## Configuration

Setup a default config in your application:

```elixir
config :pagantis_elixir_tools, ElixirTools.HttpClient,
  response_timeout: 1000 # in ms, required
  http_client: HTTPoison # optional, default: HTTPoison
```

## Usage
Client has to create `adapter` for a specific provider with implemented function `base_uri()`. 

This module should use `@behaviour PgIssuing.HttpClient.Adapter`

To do http request you add to your code the following code

```elixir
HttpClient.post(YourAdapterModule, "path/to/endpoint", "{\"param\":\"value\"}")
```