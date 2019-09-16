defmodule ElixirTools.Fixture do
  @moduledoc """
  Fixture is a helper to work with fixtures in tests.
  """

  @fixture_location "test/fixtures/"

  @doc """
  Looks for a json fixture and decodes it
  """
  @spec load_json!(String.t(), String.t()) :: term | no_return
  def load_json!(fixture, location \\ @fixture_location) do
    fixture
    |> load!(location)
    |> Jason.decode!()
  end

  @doc """
  Looks for a fixture without decoding
  """
  @spec load!(String.t(), String.t(), String.t()) :: String.t()
  def load!(fixture, location \\ @fixture_location, file_extension \\ ".json") do
    file = location <> fixture <> file_extension
    file |> File.read!()
  end
end
