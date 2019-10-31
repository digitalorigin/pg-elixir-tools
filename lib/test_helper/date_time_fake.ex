defmodule ElixirTools.TestHelper.DateTimeFake do
  use ElixirTools.ContractImpl, module: DateTime

  @datetime "2019-05-02 13:59:45.103716Z"

  @impl true
  def utc_now() do
    send(self(), :utc_now)
    @datetime
  end

  @impl true
  def to_string(datetime) do
    send(self(), {:date_time_to_string, datetime})
    @datetime
  end

  @spec get_datetime() :: DateTime.t()
  def get_datetime, do: @datetime |> DateTime.from_iso8601() |> elem(1)
end
