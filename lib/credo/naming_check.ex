defmodule ElixirTools.Credo.NamingCheck do
  @moduledoc """
  This mudule provides paths modification for typical Phoenix paths for controllers/views
  To use it add `{CredoNaming.Check.Consistency.ModuleFilename, valid_filename_callback: &CredoNamingCheck.valid_filename?/3}`
  to you .credo.exs
  """

  @parts_to_be_cleaned ["/controllers/", "/views/"]

  def valid_filename?(filepath, module_name, opts) do
    if(String.contains?(filepath, @parts_to_be_cleaned)) do
      filepath = String.replace(filepath, @parts_to_be_cleaned, "/")
      CredoNaming.Check.Consistency.ModuleFilename.valid_filename?(filepath, module_name, opts)
    else
      CredoNaming.Check.Consistency.ModuleFilename.valid_filename?(filepath, module_name, opts)
    end
  end
end
