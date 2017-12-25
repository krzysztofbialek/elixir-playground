defmodule Scraper.NasdaqScraper do
  import Scraper.NasdaqPage, only: [fetch_price_for: 2]
  @stock_names ~w(amat amd baba ea gd lrcx mu nflx nvda sq vrtx wdc)
  
  @moduledoc """
  Documentation for NasdaqScraper.
  """

  @doc """
  Used for getting premarket, after-hours or real-time prices
  for listed stock name

  ## Examples

      iex> NasdaqScraper.start([type: type])
      DOWN 0.16% $194.95

  """

  def start(type) do
    IO.puts "starting"
    Hound.start_session(driver: %{chromeOptions: %{"args" => ["--headless", "--disable-gpu"]}})

    results = Enum.map(@stock_names, fn(stock) -> fetch_price_for(stock, type) end)
    IO.puts(results)
  end
end
