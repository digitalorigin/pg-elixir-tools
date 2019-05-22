defmodule ElixirTools.Fixture do
  @moduledoc """
  Fixture is a helper to work with fixtures in tests.
  """

  @fixture_location "test/fixtures/"

  @doc """
  Looks for a json fixture and decodes it
  """
  def load_json!(fixture, location \\ @fixture_location) do
    fixture
    |> load!(location)
    |> Jason.decode!()
  end

  @doc """
  Looks for a fixture without decoding
  """
  def load!(fixture, location \\ @fixture_location) do
    file = location <> fixture <> ".json"
    file |> File.read!()
  end
end
