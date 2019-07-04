defmodule ElixirTools.Metrix.Adapters.Adapter do
  @moduledoc """
  Implements a statsd behaviour
  """
  require Logger

  @type metric :: String.t()
  @type value :: any
  @type tag_map :: map

  @callback to_tags(tag_map) :: list | map
end
