defmodule ElixirTools.Metrix.SupervisorTest do
  use ExUnit.Case, async: false

  import ElixirTools.MetrixHelper

  alias ElixirTools.Metrix

  setup :start_supervisor

  setup do
    Logger.configure(level: :debug)
  end

  describe "start_link/0" do
    test "supervisor is started" do
      pid = Process.whereis(Metrix.Supervisor)
      assert is_pid(pid)
    end

    test "starts the expected children" do
      expected_children =
        [
          {ElixirTools.Metrix, []}
        ] ++ Application.get_env(:pagantis_elixir_tools, ElixirTools.Metrix)[:recurrent_metrics]

      expected_num_children = length(expected_children)
      children = Supervisor.which_children(Metrix.Supervisor)
      assert expected_num_children == length(children)

      Enum.each(children, fn {actual_module, _, _, _} ->
        result =
          Enum.find(expected_children, fn {expected_module, _} ->
            expected_module == actual_module
          end)

        assert result
      end)

      expected = %{
        active: expected_num_children,
        specs: expected_num_children,
        supervisors: 0,
        workers: expected_num_children
      }

      assert Supervisor.count_children(Metrix.Supervisor) == expected
    end
  end
end
