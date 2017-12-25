defmodule Scraper.NasdaqPage do
  use Hound.Helpers

  def fetch_price_for(stock_name, type) do
    IO.puts("fetching #{stock_name}")
    navigate_to "http://www.nasdaq.com/symbol/#{stock_name}/#{type}"
    text = find_element(:id, "qwidget_quote") |> inner_text
    Enum.join([get_direction(), text], " ")
  end

  defp get_direction do
    if element?(:class, "arrow-green"), do: "UP", else: "DOWN"
  end

end
