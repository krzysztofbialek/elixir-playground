defmodule NasdaqScraperTest do
  use ExUnit.Case
  doctest NasdaqScraper

  test "greets the world" do
    assert NasdaqScraper.hello() == :world
  end
end
