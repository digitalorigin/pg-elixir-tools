defmodule ElixirTools.JsonApi.View do
  @moduledoc """
  JSON API View is an overlay over the default Jaserializer view and provides functionality to apply
  standards.
  """

  @type view :: String.t()

  defmacro __using__(opts) do
    alias ElixirTools.JsonApi

    quote do
      use JaSerializer, unquote(opts)

      @spec render(String.t(), map) :: map
      def render("index.json-api", data), do: JsonApi.View.render(__MODULE__, data)
      def render("show.json-api", data), do: JsonApi.View.render(__MODULE__, data)
      def render("errors.json-api", data), do: JaSerializer.PhoenixView.render_errors(data)

      @spec format_datetime(DateTime.t()) :: String.t()
      def format_datetime(value) do
        value
        |> Timex.Timezone.convert("UTC")
        |> DateTime.to_iso8601()
      end
    end
  end

  @spec render(module, map) :: map
  def render(serializer, data) do
    serializer
    |> JaSerializer.PhoenixView.render(data)
    |> format()
  end

  @spec format(map) :: map
  defp format(map) do
    for {key, value} <- ensure_map(map), into: %{} do
      {convert_key(key), convert_value(value)}
    end
  end

  @spec convert_value(any) :: any
  defp convert_value(value) when is_map(value), do: format(value)
  defp convert_value(value), do: value

  @spec convert_key(String.t() | atom) :: String.t()
  defp convert_key(key), do: ensure_dash(to_string(key))

  @spec ensure_dash(String.t()) :: String.t()
  defp ensure_dash(value), do: String.replace(value, "_", "-")

  @spec ensure_map(struct | map) :: map
  defp ensure_map(%{__struct__: _} = struct), do: Map.from_struct(struct)
  defp ensure_map(map), do: map
end
