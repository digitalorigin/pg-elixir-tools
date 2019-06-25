defmodule ElixirTools.JsonApi.ValidationPlug do
  @moduledoc """
  A Plug that checks whether a valid JSON API request is sent.

  Also prepares the request to work together with the JsonApiController by assigning the json api
  parameters to the request.
  """

  use Ecto.Schema

  import ElixirTools.JsonApi.Controller, only: [bad_input: 2, validate_params: 2]

  alias __MODULE__
  alias Plug.Conn
  alias Ecto.Changeset

  @body_methods ~w(POST PATCH DELETE PUT)
  @allowed_fields ~w(type attributes)a
  @required_fields @allowed_fields

  embedded_schema do
    field(:type, :string)
    field(:attributes, :map)
  end

  @spec init(any) :: any
  def init(default), do: default

  @spec call(Conn.t(), any) :: Conn.t()
  def call(conn = %{method: method}, _) when method in @body_methods do
    changeset = validate_params(conn.params)

    case changeset do
      {:ok, _} -> assign_json_params(conn)
      {:error, {:bad_request, errors}} -> bad_input(conn, errors)
    end
  end

  def call(conn, _), do: conn

  @spec assign_json_params(Conn.t()) :: Conn.t()
  defp assign_json_params(conn) do
    json_api_params = JaSerializer.Params.to_attributes(conn.params)

    %{conn | assigns: Map.put(conn.assigns, :json_api_params, json_api_params)}
  end

  @spec validate_params(map) :: {:ok, any} | {:error, {:bad_request, String.t()}}
  defp validate_params(%{"data" => data}) when is_map(data) do
    validate_params(data, ValidationPlug)
  end

  defp validate_params(map) when map == %{}, do: {:ok, map}
  defp validate_params(_), do: {:error, {:bad_request, "invalid json api"}}

  @spec changeset(map) :: Changeset.t()
  def changeset(params) do
    %ValidationPlug{}
    |> Changeset.cast(params, @allowed_fields, [])
    |> Changeset.validate_required(@required_fields)
  end
end
