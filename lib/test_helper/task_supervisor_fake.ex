defmodule Support.Events.TaskSupervisorFake do
  use ElixirTools.ContractImpl, module: Task.Supervisor

  @impl true
  def async_nolink(ElixirTools.TaskSupervisor, function) do
    send(self(), {:task_supervisor, :async_nolink})
    function.()
  end
end
