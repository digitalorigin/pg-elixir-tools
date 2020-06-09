defmodule ElixirTools.HttpClient do
  @moduledoc """
  The `HttpClient` module handles HTTP(s) interactions with remote services.
  """
  require Logger

  alias __MODULE__
  alias ElixirTools.IntegerHelper

  @type post_opt ::
          {:headers, [header]}
          | {:http_client, module}
          | {:retry, boolean}
          | {:headers_to_add, [header]}
  @type put_opt :: {:headers, [header]} | {:http_client, module} | {:retry, boolean}
  @type path :: String.t()
  @type query :: String.t()
  @type request_body :: String.t()
  @type response_body :: HTTPoison.Response.t()
  @type header :: {String.t(), String.t()}
  @type uri :: String.t()
  @type base_uri :: String.t()
  @type action :: :get | :create | :update
  @type adapter :: module

  @default_response_timeout 10_000

  @spec post(adapter, path, request_body, [post_opt]) :: {:ok, response_body} | {:error, term}
  def post(adapter, path, request_body, opts \\ []) do
    uri = build_uri(adapter.base_uri(), path)
    http_client = opts[:http_client] || http_client()

    post_request = fn headers, connection_options ->
      http_client.post(uri, request_body, headers, connection_options)
    end

    do_request(adapter, post_request, opts)
  end

  @spec put(adapter, path, request_body, [put_opt]) :: {:ok, response_body} | {:error, term}
  def put(adapter, path, request_body, opts \\ []) do
    uri = build_uri(adapter.base_uri(), path)
    http_client = opts[:http_client] || http_client()

    put_request = fn headers, connection_options ->
      http_client.put(uri, request_body, headers, connection_options)
    end

    do_request(adapter, put_request, opts)
  end

  @spec get(adapter, path, [post_opt]) :: {:ok, response_body} | {:error, term}
  def get(adapter, path, opts \\ []) do
    uri = build_uri(adapter.base_uri(), path)
    http_client = opts[:http_client] || http_client()

    get_request = fn headers, connection_options ->
      http_client.get(uri, headers, connection_options)
    end

    do_request(adapter, get_request, opts)
  end

  @spec build_uri(base_uri, path) :: uri | no_return
  defp build_uri(base_uri, path) do
    adapter_base_uri = ensure_valid_uri!(base_uri)
    Path.join(adapter_base_uri, path)
  end

  @spec ensure_valid_uri!(term) :: term | no_return
  defp ensure_valid_uri!(uri) when is_nil(uri) or uri == "" do
    raise("No valid provider base URI set in the config")
  end

  defp ensure_valid_uri!(uri), do: uri

  @spec do_request(adapter, fun(), [post_opt]) :: {:ok, response_body} | {:error, term}
  defp do_request(adapter, request, opts) do
    headers_to_add = opts[:headers_to_add] || []
    default_headers = opts[:headers] || adapter.default_headers()
    headers = headers_to_add ++ default_headers

    connection_options = default_connection_options()

    case request.(headers, connection_options) do
      {:ok, response} ->
        handle_do_request_response(response)

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        {:error, :http_timeout}

      {:error, %HTTPoison.Error{reason: :closed}} = response ->
        if opts[:retry_closed] do
          response
        else
          do_request(adapter, request, [{:retry_closed, true} | opts])
        end

      {:error, %HTTPoison.Error{}} = error_response ->
        error_response
    end
  end

  @spec handle_do_request_response(http_poison_response :: map) ::
          {:ok, http_poison_response :: map}
  defp handle_do_request_response(%{body: ""} = response), do: {:ok, response}

  defp handle_do_request_response(response) do
    case Jason.decode(response.body) do
      {:ok, json} ->
        {:ok, %{response | body: json}}

      {:error, _} ->
        raise "Invalid JSON returned from provider. Given: #{inspect(response.body)}"
    end
  end

  @spec http_client() :: module
  defp http_client() do
    Application.get_env(:pagantis_elixir_tools, HttpClient)[:http_client] || HTTPoison
  end

  @spec default_connection_options() :: [recv_timeout: pos_integer]
  defp default_connection_options() do
    config_timeout = Application.get_env(:pagantis_elixir_tools, HttpClient)[:response_timeout]

    timeout =
      IntegerHelper.ensure_integer("response_timeout", config_timeout, @default_response_timeout)

    [recv_timeout: timeout]
  end
end
