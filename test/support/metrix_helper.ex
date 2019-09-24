defmodule ElixirTools.MetrixHelper do
  import ExUnit.Callbacks

  alias ElixirTools.Metrix

  @doc """
  Starts the metrix supervisor. You can use this as an exunit setup callback:

  ```
  import ElixirTools.MetrixHelper

  setup :start_supervisor
  ```
  """
  def start_supervisor(_ \\ %{}) do
    initial_config = Application.get_env(:pagantis_elixir_tools, Metrix)
    tmp_config = Keyword.put(initial_config, :enabled, true)
    on_exit(fn -> Application.put_env(:pagantis_elixir_tools, Metrix, initial_config) end)
    Application.put_env(:pagantis_elixir_tools, Metrix, tmp_config)

    start_supervised(Metrix.Supervisor)

    :ok
  end
end
