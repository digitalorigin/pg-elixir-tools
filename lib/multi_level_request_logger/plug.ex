defmodule ElixirTools.MultiLevelRequestLogger.Plug do
  use Plug.Builder, init_mode: :runtime

  require Logger

  plug(Plug.Logger, builder_opts())

  @default_log_level :info
  @allowed_log_levels [:warn, :error, :info, :debug]

  @impl true
  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @impl true
  @spec call(Conn.t(), any) :: Conn.t()
  def call(conn, _opts \\ []) do
    log_level = conn |> Map.get(:request_path) |> log_level_for_path()

    super(conn, log: log_level)
  end

  defp log_level_for_path(path) do
    config = Application.get_env(:pagantis_elixir_tools, ElixirTools.MultiLevelRequestLogger)
    path_log_levels = config[:path_log_level] || %{}
    default_log_level = default_log_level(config)

    log_level = Map.get(path_log_levels, path)

    cond do
      is_nil(log_level) ->
        default_log_level

      log_level not in @allowed_log_levels ->
        Logger.warn("Invalid log level for #{path}. Using default (#{default_log_level})")
        default_log_level

      true ->
        log_level
    end
  end

  defp default_log_level(config) do
    configured_level = config[:default_log_level]

    cond do
      is_nil(configured_level) ->
        @default_log_level

      configured_level not in @allowed_log_levels ->
        Logger.error("Wrong default log level configured in configuration. Using default.")
        @default_log_level

      true ->
        configured_level
    end
  end
end
