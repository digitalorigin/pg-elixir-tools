defmodule ElixirTools.TestHelper.TaskSupervisorFakeTest do
  use ExUnit.Case, async: true

  alias ElixirTools.TestHelper.TaskSupervisorFake

  describe "async_nolink/2" do
    test "calls passed function and sends expected message" do
      assert TaskSupervisorFake.async_nolink(ElixirTools.TaskSupervisor, fn -> 42 end) == 42
      assert_received {:task_supervisor, :async_nolink}
    end
  end
end
