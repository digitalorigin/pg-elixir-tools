defmodule ElixirTools.Metrix.Adapters.Statix do
  @behaviour ElixirTools.Metrix.Adapters.Adapter

  use Statix, runtime_config: true

  @impl true
  def to_tags(tag_map) do
    tags = for {key, value} <- tag_map, do: "#{to_string(key)}:#{to_string(value)}"
    [tags: tags]
  end
end
