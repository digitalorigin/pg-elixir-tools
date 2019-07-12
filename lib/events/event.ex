defmodule ElixirTools.Events.Event do
  @moduledoc """
  A structure for working with events
  """
  alias __MODULE__

  @type t :: %Event{
          name: String.t(),
          version: String.t(),
          payload: map,
          event_id_seed: Ecto.UUID.t()
        }

  @typep return :: :ok | {:error, reason :: String.t()}

  @enforce_keys ~w(name event_id_seed)a
  defstruct [:name, :event_id_seed, payload: %{}, version: "1.0.0"]

  @spec publish(t, module | nil) :: return
  def publish(event, adapter \\ nil) do
    adapter = adapter || Application.get_env(:pagantis_elixir_tools, ElixirTools.Events)[:adapter]

    with :ok <- validate(event) do
      try do
        adapter.publish(event)
      rescue
        e -> {:error, e}
      end
    end
  end

  @spec validate(t) :: return
  def validate(event) do
    with :ok <- validate_name(event.name),
         :ok <- validate_payload(event.payload),
         :ok <- validate_version(event.version) do
      :ok
    end
  end

  @spec validate_name(any) :: return
  defp validate_name(name) do
    cond do
      !is_binary(name) ->
        {:error, "Expected a string as event name, but got #{inspect(name)}"}

      !String.contains?(name, "_") ->
        {:error, "Expected an underscore in the event name, but got #{name} instead"}

      true ->
        :ok
    end
  end

  @spec validate_payload(any) :: return
  defp validate_payload(payload) when is_map(payload), do: :ok
  defp validate_payload(_), do: {:error, "Expected payload to be a map"}

  @spec validate_version(any) :: return
  defp validate_version(version) do
    with {:is_string, true} <- {:is_string, is_binary(version)},
         {:split, [mayor, minor, fix]} <- {:split, String.split(version, ".")},
         {:parse_mayor, {_, ""}} <- {:parse_mayor, Integer.parse(mayor)},
         {:parse_minor, {_, ""}} <- {:parse_minor, Integer.parse(minor)},
         {:parse_fix, {_, ""}} <- {:parse_fix, Integer.parse(fix)} do
      :ok
    else
      {:is_string, false} -> {:error, "Expected a string with a version"}
      {:split, _} -> {:error, "Expected version with 3 dots, but received #{version}"}
      {:parse_mayor, _} -> {:error, "Expected a number for the mayor, but received #{version}"}
      {:parse_minor, _} -> {:error, "Expected a number for the minor, but received #{version}"}
      {:parse_fix, _} -> {:error, "Expected a number for the fix, but received #{version}"}
    end
  end
end
