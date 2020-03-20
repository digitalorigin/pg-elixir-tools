defmodule ElixirTools.Credo.NamingCheck do
  @moduledoc """
  This module makes CredoNaming compatible with typical Phoenix paths for controllers/views.
  To use it add `{CredoNaming.Check.Consistency.ModuleFilename, valid_filename_callback: &ElixirTools.Credo.NamingCheck.valid_filename?/3}`
  to your .credo.exs
  """
  alias CredoNaming.Check.Consistency.ModuleFilename

  @parts_to_be_cleaned ["/controllers/", "/views/"]

  def valid_filename?(filepath, module_name, opts) do
    if String.contains?(filepath, @parts_to_be_cleaned) do
      filepath = String.replace(filepath, @parts_to_be_cleaned, "/")
      ModuleFilename.valid_filename?(filepath, module_name, opts)
    else
      ModuleFilename.valid_filename?(filepath, module_name, opts)
    end
  end
end
