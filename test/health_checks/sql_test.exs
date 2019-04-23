defmodule ElixirTools.HealthChecks.SqlTest do
  use ExUnit.Case

  alias ElixirTools.HealthChecks.Sql

  defmodule FakeSQL do
    use ElixirTools.ContractImpl, module: Ecto.Adapters.SQL

    @impl true
    def query!(:repo_success, _), do: [1]
    def query!(:repo_fail, _), do: raise("Not ready exception")
  end

  describe "status/1" do
    test "when the status is ready, returns ok" do
      assert :ok == Sql.status(%{repos: [:repo_success]}, sql_module: FakeSQL)
    end

    test "when the status is not ready, returns an error" do
      assert {:error, %RuntimeError{message: "Not ready exception"}} ==
               Sql.status(%{repos: [:repo_fail]}, sql_module: FakeSQL)
    end

    test "when the second repo is not ready, returns error" do
      assert {:error, %RuntimeError{message: "Not ready exception"}} ==
               Sql.status(%{repos: [:repo_success, :repo_fail]}, sql_module: FakeSQL)
    end
  end
end
