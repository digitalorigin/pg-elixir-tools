defmodule ElixirTools.Events.Event do
  @moduledoc """
  A structure for working with events.
  `event_id_seed` is used for `event_id` generation(UUID5) together with `name` & `version`.
  So if all values are the same event will be updated.
  """
  alias ExJsonSchema.Validator

  alias __MODULE__

  @type t :: %Event{
          name: String.t(),
          version: String.t(),
          payload: map,
          event_id_seed: Ecto.UUID.t(),
          event_id_seed_optional: String.t(),
          occurred_at: DateTime.t() | nil
        }

  @typep return :: :ok | {:error, reason :: String.t()}

  @enforce_keys ~w(name event_id_seed)a
  defstruct [
    :name,
    :event_id_seed,
    :occurred_at,
    payload: %{},
    version: "1.0.0",
    event_id_seed_optional: ""
  ]

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
         :ok <- validate_event_id_seed(event.event_id_seed),
         :ok <- validate_event_id_seed_optional(event.event_id_seed_optional),
         :ok <- validate_occurred_at(event.occurred_at),
         :ok <- validate_version(event.version) do
      :ok
    end
  end

  @typep event_schema :: map
  @spec validate_json_schema(event_schema, Event.t()) :: :ok | {:error, String.t()}
  def validate_json_schema(schema, event) do
    stringified_keys_event = to_string_keys(event)

    case Validator.validate(schema, stringified_keys_event) do
      {:error, [{reason, details} | _]} -> {:error, Enum.join([reason, details], ": ")}
      :ok -> :ok
    end
  end

  @spec to_string_keys(Event.t()) :: map
  defp to_string_keys(event), do: event |> Map.from_struct() |> Jason.encode!() |> Jason.decode!()

  @spec validate_occurred_at(any) :: return
  defp validate_occurred_at(%DateTime{}), do: :ok
  defp validate_occurred_at(nil), do: :ok

  defp validate_occurred_at(value),
    do: {:error, "Expected a DateTime as occurred_at, but got #{inspect(value)}"}

  @spec validate_event_id_seed_optional(any) :: return
  defp validate_event_id_seed_optional(value) when is_binary(value), do: :ok

  defp validate_event_id_seed_optional(value),
    do: {:error, "Expected a string as event_id_seed_optional, but got #{inspect(value)}"}

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

  @spec validate_event_id_seed(any) :: return
  defp validate_event_id_seed(event_id_seed) do
    case UUID.info(event_id_seed) do
      {:ok, _} -> :ok
      _ -> {:error, "Expected a UUID string as event_id_seed, but got #{inspect(event_id_seed)}"}
    end
  end

  @spec validate_payload(any) :: return
  defp validate_payload(payload) when is_map(payload), do: :ok
  defp validate_payload(_), do: {:error, "Expected payload to be a map"}

  @spec validate_version(any) :: return
  defp validate_version(version) do
    with {:is_string, true} <- {:is_string, is_binary(version)},
         {:split, [major, minor, fix]} <- {:split, String.split(version, ".")},
         {:parse_major, {_, ""}} <- {:parse_major, Integer.parse(major)},
         {:parse_minor, {_, ""}} <- {:parse_minor, Integer.parse(minor)},
         {:parse_fix, {_, ""}} <- {:parse_fix, Integer.parse(fix)} do
      :ok
    else
      {:is_string, false} -> {:error, "Expected a string with a version"}
      {:split, _} -> {:error, "Expected version with 3 dots, but received #{version}"}
      {:parse_major, _} -> {:error, "Expected a number for the major, but received #{version}"}
      {:parse_minor, _} -> {:error, "Expected a number for the minor, but received #{version}"}
      {:parse_fix, _} -> {:error, "Expected a number for the fix, but received #{version}"}
    end
  end
end
