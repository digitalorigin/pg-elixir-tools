defmodule ElixirTools.HttpClient.Request do
  @moduledoc """
  A `Request` prepares and does the call to an external provider.
  """
  @typep json :: list | map

  @typedoc """
  The return for every request.
  """
  @type request_return :: {:ok, atom | json} | {:error, json}

  @typedoc """
  The parameters to build the request.
  """
  @type params :: map
  @type request_opt :: []

  @doc """
  Execute an action on a resource
  """
  @callback create(params, request_opt) :: request_return()
  @callback get(params, request_opt) :: request_return()
  @callback delete(params, request_opt) :: request_return()
  @callback update(params, request_opt) :: request_return()

  @optional_callbacks create: 2, get: 2, delete: 2, update: 2
end
