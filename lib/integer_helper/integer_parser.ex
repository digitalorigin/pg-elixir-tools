defmodule ElixirTools.IntegerHelper do
  @moduledoc """
  Helper module for dealing with Integers
  """

  require Logger

  @doc """
  Ensures a value is an integer. If it is not, it tries to make it an integer. If it is not
  parsable, it returns the given default with a warning
  """
  @spec ensure_integer(String.t(), any, integer) :: integer | no_return()
  def ensure_integer(_, integer, _) when is_integer(integer), do: integer
  def ensure_integer(_, string, _) when is_binary(string), do: String.to_integer(string)

  def ensure_integer(parameter_name, value, default) when is_integer(default) do
    Logger.warn(fn ->
      "#{inspect(value)} is not valid for #{parameter_name}. Using default #{default}"
    end)

    default
  end

  def ensure_integer(_, _, default) do
    raise "Default has to be an integer. Given: #{inspect(default)}"
  end
end
