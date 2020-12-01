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

  def login() do
    email = Application.fetch_env!(:harmo_import, :email)
    password = Application.fetch_env!(:harmo_import, :password)
    url = "https://api.rebased.harmonogram.rebased.pl/api/v1/access-tokens"
    {:ok, body} = Poison.encode(%{data: %{ attributes: %{ email: email, password: password} } })
    {:ok, response} = HTTPoison.post(url, body, [{"Content-Type", "application/vnd.api+json"}])
    {:ok, data} = Poison.decode(response.body)
    token = get_in(data, ["data", "attributes", "access-token"])
    token
  end

  def import_log(user_token, file) do
    file
    |> fetch_grouped_logs
    |> create_harmo_entries(user_token)
  end

  # load and group logs from CSV by date
  def fetch_grouped_logs(file) do
    file 
    |> Path.expand(__DIR__)
    |> File.stream!
    |> CSV.decode
    |> Enum.slice(1, 1000)
    |> Enum.map(fn {:ok, row} -> Enum.slice(row, 0, 4) end)
    |> Enum.group_by(fn(row) -> format_entry_date(Enum.at(row, 3)) end)
    |> Enum.map(&Tuple.to_list/1)
  end

  def format_entry_date(date_string) do
    Timex.parse!(date_string, "%F %H:%M", :strftime) |> Timex.format!("%F", :strftime)
  end

  def create_harmo_entries(grouped_logs, user_token) do    
    Enum.each(grouped_logs, fn day ->
      row_date = Timex.parse!(Enum.at(day, 0), "%F", :strftime)
      start_time = %DateTime{year: row_date.year, month: row_date.month, day: row_date.day, zone_abbr: "CET",
                      hour: 09, minute: 0, second: 0, microsecond: {0, 0},
                      utc_offset: 3600, std_offset: 1, time_zone: "Europe/Warsaw"}
      
      process_row(start_time, Enum.at(day, 1), user_token)
    end)
  end

  def process_row(start_time, [log_entry | rest], user_token) do
    headers = ["Authorization": "Bearer #{user_token}", "Content-Type": "application/vnd.api+json"]

    hours = Enum.at(log_entry, 2)

    time_shift = 
      case Regex.scan(~r"\.\d*", hours) |> length() do
        1 -> %{ hours: String.to_float(hours) |> Float.floor() |> round(), minutes: 30 }
        0 -> %{ hours: String.to_integer(hours), minutes: 0 }
      end
    IO.puts(time_shift.hours)

    end_time = Timex.shift(start_time, hours: time_shift.hours, minutes: time_shift.minutes)
    desc = "#{Enum.at(log_entry, 0)} - #{Enum.at(log_entry, 1)}"
    payload = log_entry(desc, start_time, end_time)

    case send_request(payload, headers) do
      {:ok, %HTTPoison.Response{status_code: 201}} -> 
        process_row(end_time, rest, user_token)
      {:ok, %HTTPoison.Response{status_code: _, body: body}} -> 
        Poison.decode(body) |> IO.inspect
      {:error, %HTTPoison.Error{reason: reason}} -> 
        IO.inspect(reason)
    end
  end

  def process_row(_, [],_) do
    []
  end

  def send_request(payload, headers) do
    url = "https://api.rebased.harmonogram.rebased.pl/api/v1/time-logs"
    {:ok, body} = Poison.encode(payload)
    HTTPoison.post(url, body, headers)
    # IO.puts(Poison.decode(response.body))
    # {:ok, Poison.decode(response.body)}
  end

  def log_entry(desc, starts_at, ends_at) do
    now = DateTime.to_string(Timex.now())
    %{
      data: %{
        type: "time-logs",
        attributes: %{
          description: desc,
          "starts-at": DateTime.to_string(starts_at),
          "ends-at": DateTime.to_string(ends_at),
          "created-at": now,
          "updated-at": now,
          billable: true
        },
        relationships: %{
          project: %{
              data: %{
                id: "19",
                type: "projects"
            }
          },
          user: %{
              data: %{
                id: "12",
                type: "users"
              }
          }
        }
      }
    }
  end
end
