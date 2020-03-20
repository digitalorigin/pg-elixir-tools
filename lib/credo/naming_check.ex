defmodule ElixirTools.Credo.NamingCheck do
  def valid_filename?(filepath, module_name, _opts) do
    filepath = String.replace(filepath, ["/controllers/", "/views/"], "/")

    root_path = CredoNaming.Check.Consistency.ModuleFilename.root_path(filepath)
    path = "#{Macro.underscore(module_name)}#{Path.extname(filepath)}"
    filepaths = [Path.join([root_path, path])]
    {filepath in filepaths, filepaths}
  end
end
