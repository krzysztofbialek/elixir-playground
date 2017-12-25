defmodule Scraper.NasdaqPage do
  use Hound.Helpers

  def fetch_price_for(stock_name, type) do
    IO.puts("fetching #{stock_name}")
    navigate_to "http://www.nasdaq.com/symbol/#{stock_name}/#{type}"
    Enum.join([format_stock_name(stock_name), get_direction(), get_percent(), get_price(), ~s(\n)], " ")
  end

  defp get_price do
    text = find_element(:id, "qwidget_quote") |> inner_text
    Regex.run(~r/\$\d*.\d{0,2}/, text)
  end

  defp get_percent do
    find_element(:id, "qwidget_percent") |> inner_text
  end
 
  defp get_direction do
    if element?(:class, "arrow-green"), do: "UP  ", else: "DOWN"
  end

  defp format_stock_name(stock_name) do
    name_length = String.length(stock_name)
    stock_name <> String.duplicate(" ", 4 - name_length) |> String.upcase
  end

end
