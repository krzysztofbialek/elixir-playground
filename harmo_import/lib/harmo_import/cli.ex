defmodule HarmoImport.CLI do
  def main(args) do
    args 
    |> parse_args
    |> process
  end

  def parse_args(args) do
    parse = OptionParser.parse(args, switches: [ file: :string, password: :string, email: :string ],
                                     aliases:  [ f:    :file    ])
  
    case parse do
      { file, _, _ } 
        -> file
      _ ->
        IO.puts """
          file, email and password must be present
        """

        System.halt(0)
    end
  end

  def process(file) do
    login()
    |> import_log(file)
  end

  defp login() do
    email = Application.fetch_env!(:harmo_import, :email)
    password = Application.fetch_env!(:harmo_import, :password)
    url = "https://api.rebased.harmonogram.rebased.pl/api/v1/access-tokens"
    {:ok, body} = Poison.encode(%{data: %{ attributes: %{ email: email, password: password} } })
    {:ok, response} = HTTPoison.post(url, body, [{"Content-Type", "application/vnd.api+json"}])
    {:ok, data} = Poison.decode(response.body)
    token = get_in(data, ["data", "attributes", "access-token"])
    token
  end

  defp import_log(user_token, file) do
    file
    |> fetch_grouped_logs
    |> create_harmo_entries(user_token)
  end

  # load and group logs from CSV by date
  defp fetch_grouped_logs(file) do
    file |> Path.expand(__DIR__) |> File.stream! |> CSV.decode |> Enum.slice(1, 1000) |> Enum.map(fn {:ok, row} -> Enum.slice(row, 0, 4) end) |> Enum.group_by(fn(row) -> Enum.at(row, 3) end) |> Enum.map(&Tuple.to_list/1)
  end

  defp create_harmo_entries(grouped_logs, user_token) do
    headers = ["Authorization": "Bearer #{user_token}", "Content-Type": "application/vnd.api+json"]
    
    Enum.each(grouped_logs, fn day ->
      date = Timex.parse!(Enum.at(day, 1), "%F %H:%M", :strftime)
      start_time = %DateTime{year: row_date.year, month: row_date.month, day: row_date.day, zone_abbr: "CET",
                      hour: 09, minute: 0, second: 0, microsecond: {0, 0},
                      utc_offset: 3600, std_offset: 0, time_zone: "Europe/Warsaw"}
      end_time = nil
      
      day 
      |> Enum.at(2) 
      |> Enum.each(fn log_entry ->
        hours = Enum.at(log_entry, 2)
        time_shift = 
          case Regex.scan(~r"\.\d*", hours) |> length() do
            1 -> %{ hours: String.to_float(hours) |> Float.floor(), minutes: 30 }
            0 -> %{ hours: String.to_integer(hours), minutes: 0 }
          end
        end_time = Timex.shift(start_time, time_shift.hours, time_shift.minutes)
        desc = "#{Enum.at(first, 0)} - #{Enum.at(first, 1)}"
        payload = log_entry(desc, start_time, end_time)

        {:ok, _} = send_request(payload, headers)
        start_time = end_time
      end)
    end)
  end

  def send_request(payload, headers)
    url = "https://api.rebased.harmonogram.rebased.pl/api/v1/time-logs"
    {:ok, body} = Poison.encode(payload)
    {:ok, response} = HTTPoison.post(url, body, headers)
    IO.puts(Poison.decode(response.body))
  end

  def log_entry(desc, starts_at, ends_at)
    now = DateTime.to_string(Timex.now())
    %{
      data: %{
        type: "time-logs",
        attributes: %{
          description: desc,
          "starts-at": "2020-03-23T15:00:13.000+0100",
          "ends-at": "2020-03-23T15:30:13.000+0100",
          "created-at": now,
          "updated-at": now,
          "billable": true
        },
        relationships: %{
          project: %{
              data: %{
                id: "19",
                type: "projects"
            }
          },
          user: %{
              data: {
                id: "12",
                type: "users"
              }
          }
        }
      }
    }
  end
end

# row_date = Timex.parse!(Enum.at(row, 3), "%F %H:%M", :strftime)

# start_time = %DateTime{year: row_date.year, month: row_date.month, day: row_date.day, zone_abbr: "CET",
#                 hour: 09, minute: 0, second: 0, microsecond: {0, 0},
#                 utc_offset: 3600, std_offset: 0, time_zone: "Europe/Warsaw"}

# hours = Enum.at(row, 2)
# time_shift = 
# case Regex.scan(~r"\.\d*", hours) |> length() do
#   1 -> %{ hours: String.to_float(hours) |> Float.floor(), minutes: 31 }
#   0 -> %{ hours: String.to_integer(hours), minutes: 1 }
# end

# end_time = Timex.shift(start_time, time_shift.hours, time_shift.minutes)
# desc = "#{Enum.at(first, 0)} - #{Enum.at(first, 1)}"
# payload = log_entry(desc, start_time, end_time)

