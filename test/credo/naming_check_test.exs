defmodule ElixirTools.Credo.NamingCheckTest do
  use ExUnit.Case

  alias ElixirTools.Credo.NamingCheck

  test "returns valid for a typical phoenix view module" do
    filepath = "lib/project_web/views/v1/example_view.ex"
    module_name = "ProjectWeb.V1.ExampleView"
    assert {true, _} = NamingCheck.valid_filename?(filepath, module_name, [])
  end

  test "returns valid for a typical phoenix module" do
    filepath = "lib/project/modules/etc/module.ex"
    module_name = "Project.Modules.Etc.Module"
    assert {true, _} = NamingCheck.valid_filename?(filepath, module_name, [])
  end

  test "returns not valid for a phoenix module with wrong filepath" do
    filepath = "lib/project/modules/etc/module.ex"
    module_name = "Project.Modules.Module"
    assert {false, ok_variants} = NamingCheck.valid_filename?(filepath, module_name, [])
    assert "lib/project/modules/module.ex" in ok_variants
  end
end
