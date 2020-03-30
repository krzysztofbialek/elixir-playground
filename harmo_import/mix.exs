defmodule HarmoImport.MixProject do
  use Mix.Project

  def project do
    [
      app: :harmo_import,
      version: "0.1.0",
      elixir: "~> 1.7",
      escript: escript_config(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison, :timex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:poison, "~> 3.1"},
      {:csv, "~> 2.3"},
      {:timex, "~> 3.5"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp escript_config do
    [ main_module: HarmoImport.CLI ]
  end
end
