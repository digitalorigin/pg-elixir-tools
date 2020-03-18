defmodule ElixirTools.MixProject do
  use Mix.Project

  @version "0.17.5"
  @description "Tools used in Pagantis for making developing easier"

  def project do
    [
      app: :pagantis_elixir_tools,
      version: @version,
      description: @description,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls.json": :test],
      deps: deps(),
      package: package(),
      docs: [
        extras: [
          "README.md"
        ]
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.9", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_sns, "~> 2.0"},
      {:timex, "~> 3.1"},
      {:elixir_uuid, "~> 1.2"},
      {:jason, "~> 1.1"},
      {:ja_serializer, "~> 0.14"},
      {:ecto_sql, "~> 3.0"},
      {:statix, ">= 0.0.0"},
      {:httpoison, "~> 1.4"}
    ]
  end

  defp package() do
    [
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/digitalorigin/pg-elixir-tools"}
    ]
  end
end
