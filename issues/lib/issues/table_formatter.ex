defmodule Issues.TableFormatter do
  import Enum, only: [ each: 2, map: 2, map_join: 3, max: 1 ]

  def print_table_for_columns(rows, headers) do
    IO.puts split_into_columns(rows, headers)
    with data_by_columns = split_into_columns(rows, headers),
         column_widths   = widths_of(data_by_columns, headers),
         format          = format_for(column_widths)
    do
         puts_one_line_in_columns(headers, format)
         IO.puts(separator(column_widths))
         puts_in_columns(data_by_columns, format)
    end
  end

  def split_into_columns(rows, headers) do
    for header <- headers do
      for row <- rows, do: printable(row[header])
    end
  end

  def printable(str) when is_binary(str), do: str
  def printable(str), do: to_string(str)

  def widths_of(columns, headers) do
    first_header_length = headers |> List.first |> to_string |> String.length
    columns_widths = for column <- columns, do: column |> map(&String.length/1) |> max

    if first_header_length > List.first(columns_widths) do
      List.replace_at(columns_widths, 0, first_header_length)
    else
      columns_widths
    end 
  end

  def format_for(column_widths) do
    map_join(column_widths, "|", fn width -> " ~-#{width}s " end) <> "~n" 
  end

  def separator(column_widths) do
    map_join(column_widths, "+", fn width -> List.duplicate("-", width + 2) end)
  end

  def puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip
    |> map(&Tuple.to_list/1)
    |> each(&puts_one_line_in_columns(&1, format))
  end

  def puts_one_line_in_columns(fields, format) do
    :io.format(format, fields)
  end
end
