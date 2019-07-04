defmodule ElixirTools.Metrix.Plug.Tags do
  @moduledoc """
  Module to help the Metrics plug to fetch tags
  """

  alias Plug.Conn

  @doc """
  Returns the controller name if set, nil otherwise
  """
  @spec controller_name(Conn.t()) :: String.t() | nil
  def controller_name(%{private: %{phoenix_controller: controller}}) do
    controller |> to_string() |> String.split(".") |> List.last()
  end

  def controller_name(_), do: nil

  @doc """
  Returns the method name if set, nil otherwise
  """
  @spec method_name(Conn.t()) :: String.t() | nil
  def method_name(%{private: %{phoenix_action: action}}), do: to_string(action)
  def method_name(_), do: nil

  @doc """
  Returns the code class for the response.
  """
  @spec response_status_code_class(Conn.t()) :: String.t()
  def response_status_code_class(%{status: status_code}) do
    status_code |> to_string |> String.first() |> String.pad_trailing(3, "x")
  end

  @doc """
  Returns the requested API version, based on the URL
  """
  @spec api_version(Conn.t()) :: String.t() | nil
  def api_version(%{path_info: ["v" <> _ = version | _]}), do: version
  def api_version(_), do: nil

  @doc """
  Returns the cleaned request path. It removes additional slashes.
  """
  @spec request_path(Conn.t()) :: String.t() | nil
  def request_path(%{path_info: path_info}), do: "/" <> Enum.join(path_info, "/")
end
