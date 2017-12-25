defmodule Scraper.CLI do
  import Scraper.NasdaqScraper, only: [start: 1]

  @market_types ~w(premarket after-hours real-time)

  def main(args) do
    args |> parse_args |> process
  end

  defp process(type) do
    start(type)
  end

  defp parse_args(args) do
    parse = OptionParser.parse(args,
      switches: [type: :string],
      aliases:  [t: :type]
    )
  
    case parse do
      { _, [type: type], _ } when type in @market_types
        -> type

      { _, [type: type], _ } when type not in @market_types ->
        IO.puts """
           type: must be one of premarket, after-hours, real-time
           """

        System.halt(0)

      _ -> "premarket"
    end
  end
end
    
