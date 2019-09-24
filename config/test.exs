use Mix.Config

config :pagantis_elixir_tools, ElixirTools.JsonApi.Controller,
  error_view: ElxirTools.JsonApi.Support.ErrorView

config :pagantis_elixir_tools, ElixirTools.Metrix,
  default_tags: %{default_tag: "1", other_default_tag: "2"},
  adapter: ElixirTools.Metrix.Adapters.Log,
  enabled: false,
  recurrent_metrics: []

config :pagantis_elixir_tools, ElixirTools.Schema, default_repo: Support.TestRepo

config :pagantis_elixir_tools, ElixirTools.HttpClient, response_timeout: 1500
