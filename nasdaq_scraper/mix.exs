defmodule NasdaqScraper.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nasdaq_scraper,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      escript: escript_config(),  # <- add this line
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison, :hound]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      { :httpoison, "~> 0.13" },
      { :hound, "~> 1.0" }
    ]
  end

  defp escript_config do
    [ main_module: Scraper.CLI ]
  end
end
