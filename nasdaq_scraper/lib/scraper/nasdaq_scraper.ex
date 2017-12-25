defmodule Scraper.NasdaqScraper do
  import Scraper.NasdaqPage, only: [fetch_price_for: 2]
  @stock_names ~w(nvda amd baba v)
  
  @moduledoc """
  Documentation for NasdaqScraper.
  """

  @doc """
  Hello world.

  ## Examples

      iex> NasdaqScraper.hello
      :world

  """

  def start(type) do
    IO.puts "starting"
    Hound.start_session

    results = Enum.map(@stock_names, fn(stock) -> fetch_price_for(stock, type) end)
    IO.puts(results)
  end
end
