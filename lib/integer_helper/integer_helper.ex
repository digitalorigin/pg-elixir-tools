defmodule ElixirTools.IntegerHelper do
  @moduledoc """
  Helper module for dealing with Integers
  """

  require Logger

  @doc """
  Ensures a value is an integer. If it is not, it tries to make it an integer. If it is not
  parsable, it returns the given default with a warning
  """
  @typep ensure_integer_opt :: {:telemetry, module}
  @spec ensure_integer(String.t(), any, integer, [ensure_integer_opt]) :: integer | no_return()
  def ensure_integer(key, value, default, opts \\ [])
  def ensure_integer(_, integer, _, _) when is_integer(integer), do: integer
  def ensure_integer(_, string, _, _) when is_binary(string), do: String.to_integer(string)

  def ensure_integer(parameter_name, value, default, opts) when is_integer(default) do
    telemetry_module = opts[:telemetry_module] || :telemetry

    telemetry_module.execute(
      [:pagantis_elixir_tools, :ensure_integer, :not_valid],
      %{
        error_info:
          "#{inspect(value)} is not valid for #{parameter_name}. Using default #{default}"
      }
    )

    Logger.warn(fn ->
      "#{inspect(value)} is not valid for #{parameter_name}. Using default #{default}"
    end)

    default
  end

  def ensure_integer(_, _, default, _) do
    raise "Default has to be an integer. Given: #{inspect(default)}"
  end
end
