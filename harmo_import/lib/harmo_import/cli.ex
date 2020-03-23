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
      { [file: file, email: email, password: password], _, _ } 
        -> file, email, password
      _ ->
        IO.puts """
          file, email and password must be present
        """

        System.halt(0)
    end
  end

  def process(file, email, password) do
    login(email, password)
    |> import_log(file)
  end

  defp login(email, password) do
    {:ok, body} = Poison.encode(%{data: %{ attributes: %{ email: email, password: password} } })
    {:ok, response} = HTTPoison.post(url, body, [{"Content-Type", "application/vnd.api+json"}])
    {:ok, data} = Poison.decode(response.body)
    token = get_in(data, ["data", "attributes", "access-token"])
    token
  end

  defp import_log(user_token, file) do
  end
end
